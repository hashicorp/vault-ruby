module Vault
  require_relative "vault/client"
  require_relative "vault/configurable"
  require_relative "vault/defaults"
  require_relative "vault/errors"
  require_relative "vault/response"
  require_relative "vault/version"

  require_relative "vault/api"

  extend Vault::Configurable

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
