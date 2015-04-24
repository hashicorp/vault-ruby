module Vault
  module Response
    def self.new(*members)
      Struct.new(*members) do
        def self.decode(object)
          self.new(*object.values_at(*self.members))
        end

        def to_s
          "#<#{self.class.name}>"
        end

        def inspect
          data = self.members.map { |m| "@#{m}=#{self.public_send(m).inspect}" }.join(", ")
          "#<#{self.class.name} #{data}>"
        end
      end
    end
  end
end
