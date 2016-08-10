require "json"

module Vault
  class InitResponse < Response
    # @!attribute [r] keys
    #   List of unseal keys.
    #   @return [Array<String>]
    field :keys

    # @!attribute [r] root_token
    #   Initial root token.
    #   @return [String]
    field :root_token
  end

  class InitStatus < Response
    # @!method initialized?
    #   Returns whether the Vault server is initialized.
    #   @return [Boolean]
    field :initialized, as: :initialized?
  end

  class Sys
    # Show the initialization status for this vault.
    #
    # @example
    #   Vault.sys.init_status #=> #<Vault::InitStatus initialized=true>
    #
    # @return [InitStatus]
    def init_status
      json = client.get("/v1/sys/init")
      return InitStatus.decode(json)
    end

    # Initialize a new vault.
    #
    # @example
    #   Vault.sys.init #=> #<Vault::InitResponse keys=["..."] root_token="...">
    #
    # @param [Hash] options
    #   the list of init options
    #
    # @option options [Fixnum] :shares
    #   the number of shares
    # @option options [Fixnum] :threshold
    #   the number of keys needed to unlock
    # @option options [Array] :pgp_keys
    #   an optional Array of base64-encoded PGP public keys to encrypt shares with
    #
    # @return [InitResponse]
    def init(options = {})
      json = client.put("/v1/sys/init", JSON.fast_generate(
        secret_shares:    options.fetch(:shares, 5),
        secret_threshold: options.fetch(:threshold, 3),
        pgp_keys:         options.fetch(:pgp_keys, nil)
      ))
      return InitResponse.decode(json)
    end
  end
end
