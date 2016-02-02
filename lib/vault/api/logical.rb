require_relative "secret"
require_relative "../client"
require_relative "../request"
require_relative "../response"

module Vault
  class Client
    # A proxy to the {Logical} methods.
    # @return [Logical]
    def logical
      @logical ||= Logical.new(self)
    end
  end

  class Logical < Request
    # List the secrets at the given path, if the path supports listing. If the
    # the path does not exist, an exception will be raised.
    #
    # @example
    #   Vault.logical.list("secret") #=> [#<Vault::Secret>, #<Vault::Secret>, ...]
    #
    # @param [String] path
    #   the path to list
    #
    # @return [Array<String>]
    def list(path)
      json = client.get("/v1/#{CGI.escape(path)}", list: true)
      json[:data][:keys] || []
    rescue HTTPError => e
      return [] if e.code == 404
      raise
    end

    # Read the secret at the given path. If the secret does not exist, +nil+
    # will be returned.
    #
    # @example
    #   Vault.logical.read("secret/password") #=> #<Vault::Secret lease_id="">
    #
    # @param [String] path
    #   the path to read
    #
    # @return [Secret, nil]
    def read(path)
      json = client.get("/v1/#{CGI.escape(path)}")
      return Secret.decode(json)
    rescue HTTPError => e
      return nil if e.code == 404
      raise
    end

    # Write the secret at the given path with the given data. Note that the
    # data must be a {Hash}!
    #
    # @example
    #   Vault.logical.write("secret/password", value: "secret") #=> #<Vault::Secret lease_id="">
    #
    # @param [String] path
    #   the path to write
    # @param [Hash] data
    #   the data to write
    #
    # @return [Secret]
    def write(path, data = {})
      json = client.put("/v1/#{CGI.escape(path)}", JSON.fast_generate(data))
      if json.nil?
        return true
      else
        return Secret.decode(json)
      end
    end

    # Delete the secret at the given path. If the secret does not exist, vault
    # will still return true.
    #
    # @example
    #   Vault.logical.delete("secret/password") #=> true
    #
    # @param [String] path
    #   the path to delete
    #
    # @return [true]
    def delete(path)
      client.delete("/v1/#{CGI.escape(path)}")
      return true
    end
  end
end
