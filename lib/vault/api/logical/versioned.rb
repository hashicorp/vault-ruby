require_relative "unversioned"
require_relative "../secret"
require_relative "../../client"
require_relative "../../request"
require_relative "../../response"

module Vault
  module Logical
    class Versioned < Unversioned
      # List the secrets at the given path, if the path supports listing. If the
      # the path does not exist, an exception will be raised.
      #
      # @example
      #   Vault.logical.list("secret") #=> [#<Vault::Secret>, #<Vault::Secret>, ...]
      #
      # @param [String] mount
      #   the mount point for the secret engine
      # @param [String] path
      #   the path to list
      #
      # @return [Array<String>]
      def list(mount, path = "", options = {})
        headers = extract_headers!(options)
        json = client.list("/v1/#{mount}/metadata/#{encode_path(path)}", {}, headers)
        json[:data][:keys] || []
      rescue HTTPError => e
        return [] if e.code == 404
        raise
      end

      # Read the secret at the given path. If the secret does not exist, +nil+
      # will be returned.
      #
      # @example
      #   Vault.logical.read("secret", "password") #=> #<Vault::Secret lease_id="">
      #
      # @param [String] mount
      #   the mount point for the secret engine
      # @param [String] path
      #   the path to read
      #
      # @return [Secret, nil]
      def read(mount, path, options = {})
        headers = extract_headers!(options)
        json = client.get("/v1/#{mount}/data/#{encode_path(path)}", {}, headers)
        return Secret.decode(json[:data])
      rescue HTTPError => e
        return nil if e.code == 404
        raise
      end

      # Write the secret at the given path with the given data. Note that the
      # data must be a {Hash}!
      #
      # @example
      #   Vault.logical.write("secret", "password", value: "secret") #=> #<Vault::Secret lease_id="">
      #
      # @param [String] mount
      #   the mount point for the secret engine
      # @param [String] path
      #   the path to write
      # @param [Hash] data
      #   the data to write
      #
      # @return [Secret]
      def write(mount, path, data = {}, options = {})
        headers = extract_headers!(options)
        json = client.post("/v1/#{mount}/data/#{encode_path(path)}", JSON.fast_generate(:data => data), headers)
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
      #   Vault.logical.delete("secret", "password") #=> true
      #
      # @param [String] mount
      #   the mount point for the secret engine
      # @param [String] path
      #   the path to delete
      #
      # @return [true]
      def delete(mount, path)
        client.delete("/v1/#{mount}/data/#{encode_path(path)}")
        return true
      end
    end
  end
end
