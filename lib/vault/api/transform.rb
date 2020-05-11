require_relative '../client'
require_relative '../request'

module Vault
  class Client
    # A proxy to the {Transform} methods.
    # @return [Transform]
    def transform
      @transform ||= Transform.new(self)
    end
  end

  class Transform < Request
    def encode
      # Do some encoding
    end

    def decode
      # Do some decoding
    end
  end
end

require_relative 'transform/alphabet'
require_relative 'transform/role'
require_relative 'transform/template'
require_relative 'transform/transformation'
