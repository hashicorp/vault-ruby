require "json"

require_relative "secret"
require_relative "../client"
require_relative "../request"
require_relative "../response"

module Vault
  class Certificate < Response.new(:display_name, :certificate, :policies, :ttl); end

  class Client
    # A proxy to the {AuthToken} methods.
    # @return [AuthToken]
    def auth_tls
      @auth_tls ||= AuthTLS.new(self)
    end
  end

  class AuthTLS < Request

    # This enables the auth tls cert backend
    def enable
      client.sys.enable_auth('cert', 'cert', 'Allow to login via TLS certificate')
    end

    def enabled?
      client.sys.auths.keys.include? :cert
    end

    # This disable the auth tls cert backend
    def disable
      client.sys.disable_auth('cert')
    end

    # The list of certificates in vault auth backend.
    #
    # @example
    #   Vault.auth_tls.certificates #=> ["web"]
    #
    # @return [Array<String>]
    def certificates
      json = client.get("/v1/auth/cert/certs", list: true)
      json[:data][:keys] || []
    rescue HTTPError => e
      return [] if e.code == 404
      raise
      []
    end

    # Get the certificate by the given name. If a certificate does not exist by that name,
    # +nil+ is returned.
    #
    # @example
    #   Vault.auth_tls.certificate("web")
    #   #=> #<Vault::Certificate ...>
    #
    # @return [Certificate, nil]
    def certificate(name)
      json = client.get("/v1/auth/cert/certs/#{CGI.escape(name)}")
      return Certificate.decode(json[:data])
    rescue HTTPError => e
      return nil if e.code == 404
      raise
    end

    # Saves a certificate with the given name and attributes.
    #
    # @example
    #   cert = Certificate.new('web-cert', '-----BEGIN CERTIFICATE...', "default", 3600)
    #   Vault.auth_tls.put_certificate("web", cert) #=> true
    #
    # @param [String] name
    #   the name of the certificate
    # @param [Vault::Certificate] certificate
    #   the certificate defintion
    #
    # @return [true]
    def put_certificate(name, certificate)
      client.post("/v1/auth/cert/certs/#{CGI.escape(name)}", JSON.fast_generate(certificate.to_h))
      return true
    end

    # Delete the certificate with the given name. If a certificate does not exist, vault
    # will not return an error.
    #
    # @example
    #   Vault.auth_tls.delete_certificate("web") #=> true
    #
    # @param [String] name
    #   the name of the certificate
    def delete_certificate(name)
      client.delete("/v1/auth/cert/certs/#{CGI.escape(name)}")
      return true
    end
  end
end