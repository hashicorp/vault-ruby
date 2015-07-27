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
    #   Vault.app_id.login #=> #<Vault::Secret lease_id="">
    #
    # @param [Hash] options
    #
    # @return [Secret]
    def login(options = {})
      json = client.post("/v1/auth/app-id/login", JSON.fast_generate(options))
      return Secret.decode(json)
    end
  end
end
