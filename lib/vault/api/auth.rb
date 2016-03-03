require "json"

require_relative "secret"
require_relative "../client"

module Vault
  class Client
    # A proxy to the {Auth} methods.
    # @return [Auth]
    def auth
      @auth ||= Authenticate.new(self)
    end
  end

  class Authenticate < Request
    # Authenticate via the "token" authentication method. This authentication
    # method is a bit bizarre because you already have a token, but hey,
    # whatever floats your boat.
    #
    # This method hits the `/v1/auth/token/lookup-self` endpoint after setting
    # the Vault client's token to the given token parameter. If the self lookup
    # succeeds, the token is persisted onto the client for future requests. If
    # the lookup fails, the old token (which could be unset) is restored on the
    # client.
    #
    # @example
    #   Vault.auth.token("6440e1bd-ba22-716a-887d-e133944d22bd") #=> #<Vault::Secret lease_id="">
    #   Vault.token #=> "6440e1bd-ba22-716a-887d-e133944d22bd"
    #
    # @param [String] new_token
    #   the new token to try to authenticate and store on the client
    #
    # @return [Secret]
    def token(new_token)
      old_token    = client.token
      client.token = new_token
      json = client.get("/v1/auth/token/lookup-self")
      secret = Secret.decode(json)
      return secret
    rescue
      client.token = old_token
      raise
    end

    # Authenticate via the "app-id" authentication method. If authentication is
    # successful, the resulting token will be stored on the client and used for
    # future requests.
    #
    # @example
    #   Vault.auth.app_id(
    #     "aeece56e-3f9b-40c3-8f85-781d3e9a8f68",
    #     "3b87be76-95cf-493a-a61b-7d5fc70870ad",
    #   ) #=> #<Vault::Secret lease_id="">
    #
    # @example with a custom mount point
    #   Vault.auth.app_id(
    #     "aeece56e-3f9b-40c3-8f85-781d3e9a8f68",
    #     "3b87be76-95cf-493a-a61b-7d5fc70870ad",
    #     mount: "new-app-id",
    #   )
    #
    # @param [String] app_id
    # @param [String] user_id
    # @param [Hash] options
    #   additional options to pass to the authentication call, such as a custom
    #   mount point
    #
    # @return [Secret]
    def app_id(app_id, user_id, options = {})
      payload = { app_id: app_id, user_id: user_id }.merge(options)
      json = client.post("/v1/auth/app-id/login", JSON.fast_generate(payload))
      secret = Secret.decode(json)
      client.token = secret.auth.client_token
      return secret
    end

    # Authenticate via the "userpass" authentication method. If authentication
    # is successful, the resulting token will be stored on the client and used
    # for future requests.
    #
    # @example
    #   Vault.auth.userpass("sethvargo", "s3kr3t") #=> #<Vault::Secret lease_id="">
    #
    # @example with a custom mount point
    #   Vault.auth.userpass("sethvargo", "s3kr3t", mount: "admin-login") #=> #<Vault::Secret lease_id="">
    #
    # @param [String] username
    # @param [String] password
    # @param [Hash] options
    #   additional options to pass to the authentication call, such as a custom
    #   mount point
    #
    # @return [Secret]
    def userpass(username, password, options = {})
      payload = { password: password }.merge(options)
      json = client.post("/v1/auth/userpass/login/#{CGI.escape(username)}", JSON.fast_generate(payload))
      secret = Secret.decode(json)
      client.token = secret.auth.client_token
      return secret
    end

    # Authenticate via the "ldap" authentication method. If authentication
    # is successful, the resulting token will be stored on the client and used
    # for future requests.
    #
    # @example
    #   Vault.auth.ldap("sethvargo", "s3kr3t") #=> #<Vault::Secret lease_id="">
    #
    # @param [String] username
    # @param [String] password
    # @param [Hash] options
    #   additional options to pass to the authentication call, such as a custom
    #   mount point
    #
    # @return [Secret]
    def ldap(username, password, options = {})
      payload = { password: password }.merge(options)
      json = client.post("/v1/auth/ldap/login/#{CGI.escape(username)}", JSON.fast_generate(payload))
      secret = Secret.decode(json)
      client.token = secret.auth.client_token
      return secret
    end

    # Authenticate via the GitHub authentication method. If authentication is
    # successful, the resulting token will be stored on the client and used
    # for future requests.
    #
    # @example
    #   Vault.auth.github("mypersonalgithubtoken") #=> #<Vault::Secret lease_id="">
    #
    # @param [String] github_token
    #
    # @return [Secret]
    def github(github_token)
      payload = {token: github_token}
      json = client.post("/v1/auth/github/login", JSON.fast_generate(payload))
      secret = Secret.decode(json)
      client.token = secret.auth.client_token
      return secret
    end
  end
end
