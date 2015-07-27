require "json"

require_relative "secret"
require_relative "../client"

module Vault
  class Client
    # A proxy to the {AppId} methods.
    # @return [AppId]
    def app_id
      @app_id ||= AppId.new(self)
    end
  end

  class AppId < Request
    # Create an authentication token.
    #
    # @example
    #   Vault.app_id.login('foo', 'bar') #=> #<Vault::Secret lease_id="">
    #
    # @param [String] app_id
    # @param [String] user_id
    #
    # @return [Secret]
    def login(app_id, user_id)
      payload = { app_id: app_id, user_id: user_id }
      json = client.post("/v1/auth/app-id/login", JSON.fast_generate(payload))
      client.token = Secret.decode(json).auth.client_token
      return Secret.decode(json)
    end
  end
end
