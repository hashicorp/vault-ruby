module Vault
  module Response
    def self.new(*members)
      Struct.new(*members) do
        def self.decode(object)
          self.new(*object.values_at(*self.members))
        end
      end
    end
  end
end
