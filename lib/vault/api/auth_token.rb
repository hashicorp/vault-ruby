require "json"

require_relative "secret"
require_relative "../client"
require_relative "../request"
require_relative "../response"

module Vault
  class Client
    # A proxy to the {AuthToken} methods.
    # @return [AuthToken]
    def auth_token
      @auth_token ||= AuthToken.new(self)
    end
  end

  class AuthToken < Request
    # Create an authentication token.
    #
    # @example
    #   Vault.auth_token.create #=> #<Vault::Secret lease_id="">
    #
    # @param [Hash] options
    #
    # @return [Secret]
    def create(options = {})
      json = client.post("/v1/auth/token/create", JSON.fast_generate(options))
      return Secret.decode(json)
    end

    # Create an orphaned authentication token.
    #
    # @example
    #   Vault.auth_token.create_orphan #=> #<Vault::Secret lease_id="">
    #
    # @param [Hash] options
    #
    # @return [Secret]
    def create_orphan(options = {})
      json = client.post("/v1/auth/token/create-orphan", JSON.fast_generate(options))
      return Secret.decode(json)
    end

    # Lookup information about the current token.
    #
    # @example
    #   Vault.auth_token.lookup_self("abcd-...") #=> #<Vault::Secret lease_id="">
    #
    # @param [String] token
    #
    # @return [Secret]
    def lookup(token)
      json = client.get("/v1/auth/token/lookup/#{CGI.escape(token)}")
      return Secret.decode(json)
    end

    # Lookup information about the given token.
    #
    # @example
    #   Vault.auth_token.lookup_self #=> #<Vault::Secret lease_id="">
    #
    # @return [Secret]
    def lookup_self
      json = client.get("/v1/auth/token/lookup-self")
      return Secret.decode(json)
    end

    # Renew the given authentication token.
    #
    # @example
    #   Vault.auth_token.renew("abcd-1234") #=> #<Vault::Secret lease_id="">
    #
    # @param [String] id
    #   the auth id
    # @param [Fixnum] increment
    #
    # @return [Secret]
    def renew(id, increment = 0)
      json = client.put("/v1/auth/token/renew/#{id}", JSON.fast_generate(
        increment: increment,
      ))
      return Secret.decode(json)
    end

    # Renews a lease associated with the callign token.
    #
    # @example
    #   Vault.auth_token.renew_self #=> #<Vault::Secret lease_id="">
    #
    # @param [Fixnum] increment
    #
    # @return [Secret]
    def renew_self(increment = 0)
      json = client.put("/v1/auth/token/renew-self", JSON.fast_generate(
        increment: increment,
      ))
      return Secret.decode(json)
    end

    # Revokes the token used to call it.
    #
    # @example
    #   Vault.auth_token.revoke_self #=> 204
    #
    # @return response code.
    def revoke_self
      client.post("/v1/auth/token/revoke-self")
    end

    # Revoke exactly the orphans at the id.
    #
    # @example
    #   Vault.auth_token.revoke_orphan("abcd-1234") #=> true
    #
    # @param [String] id
    #   the auth id
    #
    # @return [true]
    def revoke_orphan(id)
      client.put("/v1/auth/token/revoke-orphan/#{id}", nil)
      return true
    end

    # Revoke all auth at the given prefix.
    #
    # @example
    #   Vault.auth_token.revoke_prefix("abcd-1234") #=> true
    #
    # @param [String] id
    #   the auth id
    #
    # @return [true]
    def revoke_prefix(prefix)
      client.put("/v1/auth/token/revoke-prefix/#{prefix}", nil)
      return true
    end

    # Revoke all auths in the tree.
    #
    # @example
    #   Vault.auth_token.revoke_tree("abcd-1234") #=> true
    #
    # @param [String] id
    #   the auth id
    #
    # @return [true]
    def revoke_tree(id)
      client.put("/v1/auth/token/revoke/#{id}", nil)
      return true
    end
  end
end
