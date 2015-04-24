module Vault
  class VaultError < RuntimeError; end

  class MissingTokenError < VaultError
    def initialize
      super <<-EOH
Missing Vault token! I cannot make requests to Vault without a token. Please
set a Vault token:

    Vault.token = "42d1dee5-eb6e-102c-8d23-cc3ba875da51"

Please refer to the documentation for more examples.
EOH
    end
  end

  class HTTPConnectionError < VaultError
    attr_reader :endpoint

    def initialize(endpoint)
      @endpoint = endpoint

      super <<-EOH
The Vault server at `#{endpoint}' is not currently
accepting connections. Please ensure that the server is running an that your
authentication information is correct.
EOH
    end
  end

  class HTTPError < VaultError
    attr_reader :endpoint, :code, :errors

    def initialize(endpoint, code, errors = [])
      @endpoint, @code, @errors = endpoint, code.to_i, errors
      errors = errors.map { |error| "  * #{error}" }

      super <<-EOH
The Vault server at `#{endpoint}' responded with a #{code}.
Any additional information the server supplied is shown below:

#{errors.join("\n").rstrip}

Please refer to the documentation for help.
EOH
    end
  end
end
