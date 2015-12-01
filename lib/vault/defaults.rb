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
    DEFAULT_RETRY_ATTEMPTS = 1

    # The default backoff interval.
    # @return [Fixnum]
    DEFAULT_RETRY_BASE = 0.05

    # The default amount of time for a single request to timeout.
    DEFAULT_RETRY_MAX_WAIT = 2.0

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
        if VAULT_DISK_TOKEN.exist? && VAULT_DISK_TOKEN.readable?
          VAULT_DISK_TOKEN.read
        else
          ENV["VAULT_TOKEN"]
        end
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

      # The number of retries when communicating with the Vault server. The
      # Vault gem will attempt to retry any server-level errors (5xx) that
      # occur during communication. The higher this value, the more attempts
      # that are made, but it also increases the amount of time the process is
      # busy waiting for a response from the server. If you are running a
      # single-threaded application, this could be a performance impact!
      # @return [Fixnum]
      def retry_attempts
        if ENV["VAULT_RETRY_ATTEMPTS"].nil?
          DEFAULT_RETRY_ATTEMPTS
        else
          ENV["VAULT_RETRY_ATTEMPTS"].to_i
        end
      end

      # The base interval for retry exponential backoff. This value will be used
      # to square the 2 value and should be combined with {retry_attempts} to
      # control the number and rate of retries for bad server responses.
      # @return [Fixnum]
      def retry_base
        if ENV["VAULT_RETRY_BASE"].nil?
          DEFAULT_RETRY_BASE
        else
          ENV["VAULT_RETRY_BASE"].to_i
        end
      end

      # The maximum amount of time for a single exponential backoff to sleep.
      # This is the upper bound on _each_ request, not the entire retry loop. If
      # you want to limit the duration of the outer retry, you should combine
      # {retry_attempts} and {retry_interval} to limit the number of attempts
      # and the space between them.
      # @return [Fixnum]
      def retry_max_wait
        if ENV["VAULT_RETRY_MAX_WAIT"].nil?
          DEFAULT_RETRY_MAX_WAIT
        else
          ENV["VAULT_RETRY_MAX_WAIT"].to_i
        end
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
