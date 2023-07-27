# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

require "open-uri"
require "singleton"
require "timeout"
require "tempfile"

module RSpec
  class VaultServer
    include Singleton

    TOKEN_PATH = File.expand_path("~/.vault-token").freeze
    TOKEN_PATH_BKUP = "#{TOKEN_PATH}.bak".freeze

    def self.method_missing(m, *args, &block)
      self.instance.public_send(m, *args, &block)
    end

    attr_reader :token
    attr_reader :unseal_token

    def initialize
      # If there is already a vault-token, we need to move it so we do not
      # clobber!
      if File.exist?(TOKEN_PATH)
        FileUtils.mv(TOKEN_PATH, TOKEN_PATH_BKUP)
        at_exit do
          FileUtils.mv(TOKEN_PATH_BKUP, TOKEN_PATH)
        end
      end

      io = Tempfile.new("vault-server")
      pid = Process.spawn(
        "vault server -dev -dev-root-token-id=root",
        out: io.to_i, err: io.to_i
      )

      at_exit do
        Process.kill("INT", pid)
        Process.waitpid2(pid)

        io.close
        io.unlink
      end
      wait_for_ready
      puts "vault server is ready"
      # sleep to get unseal token
      sleep 5

      @token = "root"

      output = ""
      while io.rewind
        output = io.read
        break unless output.empty?
      end

      if output.match(/Unseal Key.*: (.+)/)
        @unseal_token = $1.strip
      else
        raise "Vault did not return an unseal token!"
      end
    end

    def address
      "http://127.0.0.1:8200"
    end

    def wait_for_ready
      uri = URI(address + "/v1/sys/health")
      Timeout.timeout(15) do
        loop do
          begin
            response = Net::HTTP.get_response(uri)
            if response.code != 200
              return true
            end
          rescue Errno::ECONNREFUSED
            puts "waiting for vault to start"
          end
          sleep 2
        end
      end
    rescue Timeout::Error
      raise TimeoutError, "Timed out waiting for vault health check"
    end
  end
end
