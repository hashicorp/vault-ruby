module Vault
  require_relative "vault/client"
  require_relative "vault/configurable"
  require_relative "vault/defaults"
  require_relative "vault/errors"
  require_relative "vault/response"
  require_relative "vault/version"

  require_relative "vault/api"

  class << self
    # API client object based off the configured options in {Configurable}.
    #
    # @return [Vault::Client]
    attr_reader :client

    def setup!
      @client = Vault::Client.new

      # Set secure SSL options
      OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options] &= ~OpenSSL::SSL::OP_DONT_INSERT_EMPTY_FRAGMENTS
      OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options] |= OpenSSL::SSL::OP_NO_COMPRESSION
      OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options] |= OpenSSL::SSL::OP_NO_SSLv2
      OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options] |= OpenSSL::SSL::OP_NO_SSLv3

      self
    end

    # Delegate all methods to the client object, essentially making the module
    # object behave like a {Client}.
    def method_missing(m, *args, &block)
      if client.respond_to?(m)
        client.send(m, *args, &block)
      else
        super
      end
    end

    # Delegating +respond_to+ to the {Client}.
    def respond_to_missing?(m, include_private = false)
      client.respond_to?(m, include_private) || super
    end
  end
end

# Load the initial default values
Vault.setup!
