require_relative "../response"

module Vault
  # Secret is a representation of a secret.
  class Secret < Response.new(:lease_id, :lease_duration, :renewable, :data, :auth)
    alias_method :renewable?, :renewable

    alias_method :raw_auth, :auth
    def auth
      return @auth if defined?(@auth)
      if raw_auth.nil?
        @auth = nil
      else
        @auth = SecretAuth.decode(raw_auth)
      end
    end
  end

  # SecretAuth is a struct that contains the information about auth data if present.
  class SecretAuth < Response.new(:client_token, :policies, :metadata, :lease_duration, :renewable)
    alias_method :renewable?, :renewable
  end
end
