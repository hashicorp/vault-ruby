require "cgi"
require "cgi/cookie"
require "json"
require "net/http"
require "net/https"
require "uri"

require_relative "configurable"
require_relative "errors"
require_relative "version"

module Vault
  class Client
    # The user agent for this client.
    USER_AGENT = "VaultRuby/#{Vault::VERSION} (+github.com/hashicorp/vault-ruby)".freeze

    # The default headers that are sent with every request.
    DEFAULT_HEADERS = {
      "Content-Type" => "application/json",
      "Accept"       => "application/json",
      "User-Agent"   => USER_AGENT,
    }.freeze

    # The default list of options to use when parsing JSON.
    JSON_PARSE_OPTIONS = {
      max_nesting:      false,
      create_additions: false,
      symbolize_names:  true,
    }.freeze

    include Vault::Configurable

    # Create a new Client with the given options. Any options given take
    # precedence over the default options.
    #
    # @return [Vault::Client]
    def initialize(options = {})
      # Use any options given, but fall back to the defaults set on the module
      Vault::Configurable.keys.each do |key|
        value = if options[key].nil?
          Vault.instance_variable_get(:"@#{key}")
        else
          options[key]
        end

        instance_variable_set(:"@#{key}", value)
      end
    end

    # Determine if the given options are the same as ours.
    # @return [true, false]
    def same_options?(opts)
      options.hash == opts.hash
    end

    # Perform a GET request.
    # @see Client#request
    def get(path, params = {}, headers = {})
      request(:get, path, params, headers)
    end

    # Perform a POST request.
    # @see Client#request
    def post(path, data, headers = {})
      request(:post, path, data, headers)
    end

    # Perform a PUT request.
    # @see Client#request
    def put(path, data, headers = {})
      request(:put, path, data, headers)
    end

    # Perform a PATCH request.
    # @see Client#request
    def patch(path, data, headers = {})
      request(:patch, path, data, headers)
    end

    # Perform a DELETE request.
    # @see Client#request
    def delete(path, params = {}, headers = {})
      request(:delete, path, params, headers)
    end

    # Make an HTTP request with the given verb, data, params, and headers. If
    # the response has a return type of JSON, the JSON is automatically parsed
    # and returned as a hash; otherwise it is returned as a string.
    #
    # @raise [HTTPError]
    #   if the request is not an HTTP 200 OK
    #
    # @param [Symbol] verb
    #   the lowercase symbol of the HTTP verb (e.g. :get, :delete)
    # @param [String] path
    #   the absolute or relative path from {Defaults.address} to make the
    #   request against
    # @param [#read, Hash, nil] data
    #   the data to use (varies based on the +verb+)
    # @param [Hash] headers
    #   the list of headers to use
    #
    # @return [String, Hash]
    #   the response body
    def request(verb, path, data = {}, headers = {})
      # All requests to vault require a token, so we should error without even
      # trying if there is no token set
      raise MissingTokenError if token.nil?

      # Build the URI and request object from the given information
      uri = build_uri(verb, path, data)
      request = class_for_request(verb).new(uri.request_uri)

      # Add headers
      headers = DEFAULT_HEADERS.merge(headers)
      headers.each do |key, value|
        request.add_field(key, value)
      end

      # Setup PATCH/POST/PUT
      if [:patch, :post, :put].include?(verb)
        if data.respond_to?(:read)
          request.content_length = data.size
          request.body_stream = data
        elsif data.is_a?(Hash)
          request.form_data = data
        else
          request.body = data
        end
      end

      # Create the HTTP connection object - since the proxy information defaults
      # to +nil+, we can just pass it to the initializer method instead of doing
      # crazy strange conditionals.
      connection = Net::HTTP.new(uri.host, uri.port,
        proxy_address, proxy_port, proxy_username, proxy_password)

      # Create the cookie for the request.
      cookie = CGI::Cookie.new
      cookie.name    = "token"
      cookie.value   = token
      cookie.path    = "/"
      cookie.expires = Time.now + (60*60*24*376)

      # Apply SSL, if applicable
      if uri.scheme == "https"
        # Turn on SSL
        connection.use_ssl = true

        # Vault requires TLS1.2
        connection.ssl_version = :TLSv1_2

        # Turn on secure cookies
        cookie.secure = true

        # Custom pem files, no problem!
        if ssl_pem_file
          pem = File.read(ssl_pem_file)
          connection.cert = OpenSSL::X509::Certificate.new(pem)
          connection.key = OpenSSL::PKey::RSA.new(pem)
          connection.verify_mode = OpenSSL::SSL::VERIFY_PEER
        end

        # Use custom CA cert for verification
        if ssl_ca_cert
          connection.ca_file = ssl_ca_cert
        end

        # Use custom CA path that contains CA certs
        if ssl_ca_path
          connection.ca_path = ssl_ca_path
        end

        # Naughty, naughty, naughty! Don't blame me when someone hops in
        # and executes a MITM attack!
        unless ssl_verify
          connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end

      # Add the cookie to the request.
      request["Cookie"] = cookie.to_s

      # Create a connection using the block form, which will ensure the socket
      # is properly closed in the event of an error.
      connection.start do |http|
        response = http.request(request)

        case response
        when Net::HTTPRedirection
          redirect = URI.parse(response["location"])
          request(verb, redirect, data, headers)
        when Net::HTTPSuccess
          success(response)
        else
          error(response)
        end
      end
    rescue SocketError, Errno::ECONNREFUSED, EOFError
      raise HTTPConnectionError.new(address)
    end

    # Construct a URL from the given verb and path. If the request is a GET or
    # DELETE request, the params are assumed to be query params are are
    # converted as such using {Client#to_query_string}.
    #
    # If the path is relative, it is merged with the {Defaults.address}
    # attribute. If the path is absolute, it is converted to a URI object and
    # returned.
    #
    # @param [Symbol] verb
    #   the lowercase HTTP verb (e.g. :+get+)
    # @param [String] path
    #   the absolute or relative HTTP path (url) to get
    # @param [Hash] params
    #   the list of params to build the URI with (for GET and DELETE requests)
    #
    # @return [URI]
    def build_uri(verb, path, params = {})
      # Add any query string parameters
      if [:delete, :get].include?(verb)
        path = [path, to_query_string(params)].compact.join("?")
      end

      # Parse the URI
      uri = URI.parse(path)

      # Don't merge absolute URLs
      uri = URI.parse(File.join(address, path)) unless uri.absolute?

      # Return the URI object
      uri
    end

    # Helper method to get the corresponding {Net::HTTP} class from the given
    # HTTP verb.
    #
    # @param [#to_s] verb
    #   the HTTP verb to create a class from
    #
    # @return [Class]
    def class_for_request(verb)
      Net::HTTP.const_get(verb.to_s.capitalize)
    end

    # Convert the given hash to a list of query string parameters. Each key and
    # value in the hash is URI-escaped for safety.
    #
    # @param [Hash] hash
    #   the hash to create the query string from
    #
    # @return [String, nil]
    #   the query string as a string, or +nil+ if there are no params
    def to_query_string(hash)
      hash.map do |key, value|
        "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
      end.join('&')[/.+/]
    end

    # Parse the response object and manipulate the result based on the given
    # +Content-Type+ header. For now, this method only parses JSON, but it
    # could be expanded in the future to accept other content types.
    #
    # @param [HTTP::Message] response
    #   the response object from the request
    #
    # @return [String, Hash]
    #   the parsed response, as an object
    def success(response)
      if response.body && (response.content_type || '').include?("json")
        JSON.parse(response.body, JSON_PARSE_OPTIONS)
      else
        response.body
      end
    end

    # Raise a response error, extracting as much information from the server's
    # response as possible.
    #
    # @raise [HTTPError]
    #
    # @param [HTTP::Message] response
    #   the response object from the request
    def error(response)
      if (response.content_type || '').include?("json")
        # Attempt to parse the error as JSON
        begin
          json = JSON.parse(response.body, JSON_PARSE_OPTIONS)

          if json[:errors]
            raise HTTPError.new(address, response.code, json[:errors])
          end
        rescue JSON::ParserError; end
      end

      raise HTTPError.new(address, response.code, [response.body])
    end
  end
end
