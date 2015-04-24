require "singleton"
require "tempfile"

module RSpec
  module Vault
    class Server
      include Singleton

      def self.method_missing(m, *args, &block)
        self.instance.public_send(m, *args, &block)
      end

      attr_reader :token
      attr_reader :shard

      def initialize
        @pid = Process.spawn("vault server -config #{config.path}", [:out, :err] => "/dev/null")

        at_exit do
          Process.kill("INT", @pid)
          Process.wait(@pid)
        end

        output = `vault init -key-shares 1 -key-threshold 1 -address #{address}`
        raise RuntimeError, "Bad response during init!" if !$?.success?

        if output.match("^Key 1: (.+)$")
          @shard = $1.strip
        else
          raise RuntimeError, "Bad response from Vault"
        end

        if output.match("^Initial Root Token: (.+)$")
          @token = $1.strip
        else
          raise RuntimeError, "Bad response from Vault"
        end

        output = `vault unseal -address #{address} #{shard}`
        raise RuntimeError, "Bad response unsealing!" if !$?.success?
      end

      def stop
        @config.unlink
      end

      def address
        "http://127.0.0.1:#{port}"
      end

      def config
        return @config if defined?(@config)

        @config = Tempfile.new("vault")
        @config.write <<-EOH.gsub(/^ {10}/, "")
          backend "inmem" {}

          listener "tcp" {
            address = "127.0.0.1:#{port}"
            tls_disable = 1
          }
        EOH
        @config.rewind
        @config.close
        @config
      end

      private

      def port
        return @port if defined?(@port)

        server = TCPServer.new("127.0.0.1", 0)
        @port  = server.addr[1].to_i
        server.close

        return @port
      end
    end
  end
end
