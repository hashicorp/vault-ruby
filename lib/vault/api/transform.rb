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

    def role
      @role ||= Role.new(self.client)
    end

    def transformation
      @transformation ||= Transformation.new(self.client)
    end

    def template
      @template ||= Template.new(self.client)
    end

    def alphabet
      @alphabet ||= Alphabet.new(self.client)
    end
  end
end

require_relative 'transform/alphabet'
require_relative 'transform/role'
require_relative 'transform/template'
require_relative 'transform/transformation'
