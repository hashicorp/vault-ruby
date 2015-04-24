module Vault
  class Request
    attr_reader :client

    def initialize(client)
      @client = client
    end

    # @return [String]
    def to_s
      "#<#{self.class.name}>"
    end

    # @return [String]
    def inspect
      "#<#{self.class.name}:0x#{"%x" % (self.object_id << 1)}>"
    end
  end
end
