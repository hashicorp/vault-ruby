require_relative "defaults"

module Vault
  module Configurable
    def self.keys
      @keys ||= [
        :address,
        :token,
        :open_timeout,
        :proxy_address,
        :proxy_password,
        :proxy_port,
        :proxy_username,
        :read_timeout,
        :ssl_pem_file,
        :ssl_ca_cert,
        :ssl_ca_path,
        :ssl_verify,
        :ssl_timeout,
        :timeout,
      ]
    end

    Vault::Configurable.keys.each(&method(:attr_accessor))

    # Configure yields self for block-style configuration.
    #
    # @yield [self]
    def configure
      yield self
    end

    # Reset all the values to their defaults.
    #
    # @return [self]
    def reset!
      defaults = Defaults.options
      Vault::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", defaults[key])
      end
      self
    end
    alias_method :setup!, :reset!

    # The list of options for this configurable.
    #
    # @return [Hash<Symbol, Object>]
    def options
      Hash[*Vault::Configurable.keys.map do |key|
        [key, instance_variable_get(:"@#{key}")]
      end.flatten]
    end
  end
end
