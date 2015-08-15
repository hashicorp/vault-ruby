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
      json = client.get("/v1/#{path}")
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
      json = client.put("/v1/#{path}", JSON.fast_generate(data))
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
      client.delete("/v1/#{path}")
      return true
    end
  end
end
