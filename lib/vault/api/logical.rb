require_relative "secret"
require_relative "../client"
require_relative "../request"
require_relative "../response"

module Vault
  class Client
    # A proxy to the {Logical} methods.
    # @return [Logical]
    def logical
      @logical ||= Logical.new(self)
    end
  end

  class Logical < Request
    # List the secrets at the given path, if the path supports listing. If the
    # the path does not exist, an exception will be raised.
    #
    # @example
    #   Vault.logical.list("secret") #=> [#<Vault::Secret>, #<Vault::Secret>, ...]
    #
    # @param [String] path
    #   the path to list
    #
    # @return [Array<String>]
    def list(path)
      json = client.get("/v1/#{CGI.escape(path)}", list: true)
      json[:data][:keys] || []
    rescue HTTPError => e
      return [] if e.code == 404
      raise
    end

    # Read the secret at the given path. If the secret does not exist, +nil+
    # will be returned.
    #
    # @example
    #   Vault.logical.read("secret/password") #=> #<Vault::Secret lease_id="">
    #
    # @param [String] path
    #   the path to read
    #
    # @return [Secret, nil]
    def read(path)
      json = client.get("/v1/#{CGI.escape(path)}")
      return Secret.decode(json)
    rescue HTTPError => e
      return nil if e.code == 404
      raise
    end

    # Write the secret at the given path with the given data. Note that the
    # data must be a {Hash}!
    #
    # @example
    #   Vault.logical.write("secret/password", value: "secret") #=> #<Vault::Secret lease_id="">
    #
    # @param [String] path
    #   the path to write
    # @param [Hash] data
    #   the data to write
    #
    # @return [Secret]
    def write(path, data = {})
      json = client.put("/v1/#{CGI.escape(path)}", JSON.fast_generate(data))
      if json.nil?
        return true
      else
        return Secret.decode(json)
      end
    end

    # Delete the secret at the given path. If the secret does not exist, vault
    # will still return true.
    #
    # @example
    #   Vault.logical.delete("secret/password") #=> true
    #
    # @param [String] path
    #   the path to delete
    #
    # @return [true]
    def delete(path)
      client.delete("/v1/#{CGI.escape(path)}")
      return true
    end

    # Unwrap the data stored against the given token. If the secret does not exist, +nil+
    # will be returned.
    #
    # @example
    #   Vault.logical.unwrap("f363dba8-25a7-08c5-430c-00b2367124e6") #=> #<Vault::Secret lease_id="">
    #
    # @param [String] wrapper_token
    #   the token to unwrap
    #
    # @return [Secret, nil]
    def unwrap(wrapper_token)
      json = client.get("/v1/cubbyhole/response", {}, { Vault::Client::TOKEN_HEADER => wrapper_token })
      secret = Secret.decode(json)
      secret.instance_variable_set("@data", Vault::Secret.new(JSON.parse(secret.data[:response], symbolize_names: true))) if secret.data
      return secret
    rescue HTTPError => e
      return nil if e.code == 404
      raise
    end

    # Unwrap a token in a wrapped response given the temporary token.
    #
    # @example
    #   Vault.logical.unwrap("f363dba8-25a7-08c5-430c-00b2367124e6") #=> '0f0f40fd-06ce-4af1-61cb-cdc12796f42b'
    #
    # @param [String, Secret] wrapper_token
    #   the token to unwrap as a string or Vault::Secret response
    #
    # @return [String]
    def unwrap_token(wrapper_token)
      wrapper_token = wrapper_token.wrap_info.token if wrapper_token.is_a?(Vault::Secret) && wrapper_token.wrap_info
      unwrapped_token_response = unwrap(wrapper_token)
      return unwrapped_token_response.data.auth.client_token
    rescue HTTPError => e
      raise
    end
  end
end
