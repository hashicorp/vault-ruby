require "pathname"

module Vault
  module Defaults
    # The default vault address.
    # @return [String]
    VAULT_ADDRESS = "https://127.0.0.1:8200".freeze

    # The path to the vault token on disk.
    # @return [String]
    VAULT_DISK_TOKEN = Pathname.new("#{ENV["HOME"]}/.vault-token").expand_path.freeze

    # The list of SSL ciphers to allow. You should not change this value unless
    # you absolutely know what you are doing!
    # @return [String]
    SSL_CIPHERS = "TLSv1.2:!aNULL:!eNULL".freeze

    # The default number of attempts.
    # @return [Fixnum]
    RETRY_ATTEMPTS = 2

    # The default backoff interval.
    # @return [Fixnum]
    RETRY_BASE = 0.05

    # The maximum amount of time for a single exponential backoff to sleep.
    RETRY_MAX_WAIT = 2.0

    class << self
      # The list of calculated options for this configurable.
      # @return [Hash]
      def options
        Hash[*Configurable.keys.map { |key| [key, public_send(key)] }.flatten]
      end

      # The address to communicate with Vault.
      # @return [String]
      def address
        ENV["VAULT_ADDR"] || VAULT_ADDRESS
      end

      # The vault token to use for authentiation.
      # @return [String, nil]
      def token
        if !ENV["VAULT_TOKEN"].nil?
          return ENV["VAULT_TOKEN"]
        end

        if VAULT_DISK_TOKEN.exist? && VAULT_DISK_TOKEN.readable?
          return VAULT_DISK_TOKEN.read
        end

        nil
      end

      # The number of seconds to wait when trying to open a connection before
      # timing out
      # @return [String, nil]
      def open_timeout
        ENV["VAULT_OPEN_TIMEOUT"]
      end

      # The HTTP Proxy server address as a string
      # @return [String, nil]
      def proxy_address
        ENV["VAULT_PROXY_ADDRESS"]
      end

      # The HTTP Proxy server username as a string
      # @return [String, nil]
      def proxy_username
        ENV["VAULT_PROXY_USERNAME"]
      end

      # The HTTP Proxy user password as a string
      # @return [String, nil]
      def proxy_password
        ENV["VAULT_PROXY_PASSWORD"]
      end

      # The HTTP Proxy server port as a string
      # @return [String, nil]
      def proxy_port
        ENV["VAULT_PROXY_PORT"]
      end

      # The number of seconds to wait when reading a response before timing out
      # @return [String, nil]
      def read_timeout
        ENV["VAULT_READ_TIMEOUT"]
      end

      # The ciphers that will be used when communicating with vault over ssl
      # You should only change the defaults if the ciphers are not available on
      # your platform and you know what you are doing
      # @return [String]
      def ssl_ciphers
        ENV["VAULT_SSL_CIPHERS"] || SSL_CIPHERS
      end

      # The path to a pem on disk to use with custom SSL verification
      # @return [String, nil]
      def ssl_pem_file
        ENV["VAULT_SSL_CERT"]
      end

      # Passphrase to the pem file on disk to use with custom SSL verification
      # @return [String, nil]
      def ssl_pem_passphrase
        ENV["VAULT_SSL_CERT_PASSPHRASE"]
      end

      # The path to the CA cert on disk to use for certificate verification
      # @return [String, nil]
      def ssl_ca_cert
        ENV["VAULT_CACERT"]
      end
      #
      # The path to the directory on disk holding CA certs to use
      # for certificate verification
      # @return [String, nil]
      def ssl_ca_path
        ENV["VAULT_CAPATH"]
      end

      # Verify SSL requests (default: true)
      # @return [true, false]
      def ssl_verify
        # Vault CLI uses this envvar, so accept it by precedence
        if !ENV["VAULT_SKIP_VERIFY"].nil?
          return true
        end

        if ENV["VAULT_SSL_VERIFY"].nil?
          true
        else
          %w[t y].include?(ENV["VAULT_SSL_VERIFY"].downcase[0])
        end
      end

      # The number of seconds to wait for connecting and verifying SSL
      # @return [String, nil]
      def ssl_timeout
        ENV["VAULT_SSL_TIMEOUT"]
      end

      # A default meta-attribute to set all timeout values - individually set
      # timeout values will take precedence
      # @return [String, nil]
      def timeout
        ENV["VAULT_TIMEOUT"]
      end
    end
  end
end
