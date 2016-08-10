require "json"

module Vault
  class Auth < Response
    # @!attribute [r] description
    #   Description of the auth backend.
    #   @return [String]
    field :description

    # @!attribute [r] type
    #   Name of the auth backend.
    #   @return [String]
    field :type
  end

  class Sys
    # List all auths in Vault.
    #
    # @example
    #   Vault.sys.auths #=> {:token => #<Vault::Auth type="token", description="token based credentials">}
    #
    # @return [Hash<Symbol, Auth>]
    def auths
      json = client.get("/v1/sys/auth")
      json = json[:data] if json[:data]
      return Hash[*json.map do |k,v|
        [k.to_s.chomp("/").to_sym, Auth.decode(v)]
      end.flatten]
    end

    # Enable a particular authentication at the given path.
    #
    # @example
    #   Vault.sys.enable_auth("github", "github") #=> true
    #
    # @param [String] path
    #   the path to mount the auth
    # @param [String] type
    #   the type of authentication
    # @param [String] description
    #   a human-friendly description (optional)
    #
    # @return [true]
    def enable_auth(path, type, description = nil)
      payload = { type: type }
      payload[:description] = description if !description.nil?

      client.post("/v1/sys/auth/#{CGI.escape(path)}", JSON.fast_generate(payload))
      return true
    end

    # Disable a particular authentication at the given path. If not auth
    # exists at that path, an error will be raised.
    #
    # @example
    #   Vault.sys.disable_auth("github") #=> true
    #
    # @param [String] path
    #   the path to disable
    #
    # @return [true]
    def disable_auth(path)
      client.delete("/v1/sys/auth/#{CGI.escape(path)}")
      return true
    end
  end
end
