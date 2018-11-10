require_relative "logical/unversioned"
require_relative "logical/versioned"

module Vault
  class Client
    LOGICAL_APPROACHES = {
      unversioned: Logical::Unversioned,
      versioned:   Logical::Versioned
    }.freeze

    # A proxy to the {Logical} methods.
    # @return [Logical::Unversioned, Logical::Versioned]
    def logical(approach = :unversioned)
      logicals[approach]
    end

    private

    def logicals
      @logicals ||= Hash.new do |hash, key|
        hash[key] = LOGICAL_APPROACHES.fetch(key).new(self)
      end
    end
  end

  module Logical
  end
end
