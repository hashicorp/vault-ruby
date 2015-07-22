module Vault
  require_relative "vault/client"
  require_relative "vault/configurable"
  require_relative "vault/defaults"
  require_relative "vault/errors"
  require_relative "vault/response"
  require_relative "vault/version"

  require_relative "vault/api"

  extend Vault::Configurable

  # Sets the initial configurable values and tunes SSL to be more secure.
  #
  # @return [self]
  def self.setup!
    reset!

    # Set secure SSL options
    OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options] &= ~OpenSSL::SSL::OP_DONT_INSERT_EMPTY_FRAGMENTS
    OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options] |= OpenSSL::SSL::OP_NO_COMPRESSION
    OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options] |= OpenSSL::SSL::OP_NO_SSLv2
    OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options] |= OpenSSL::SSL::OP_NO_SSLv3
    self
  end

  # API client object based off the configured options in {Configurable}.
  #
  # @return [Vault::Client]
  def self.client
    if !defined?(@client) || !@client.same_options?(options)
      @client = Vault::Client.new(options)
    end
    @client
  end

  # Delegate all methods to the client object, essentially making the module
  # object behave like a {Client}.
  def self.method_missing(m, *args, &block)
    if client.respond_to?(m)
      client.send(m, *args, &block)
    else
      super
    end
  end

  # Delegating +respond_to+ to the {Client}.
  def self.respond_to_missing?(m, include_private = false)
    client.respond_to?(m) || super
  end
end

# Load the initial default values
Vault.setup!
