require "open-uri"
require "singleton"
require "timeout"
require "tempfile"
require "testcontainers"

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

    def initialize(vault_version = "latest")
      @container = Testcontainers::DockerContainer.new("hashicorp/vault:#{vault_version}")
                                                  .with_exposed_port(8200)
                                                  .with_env(VAULT_DEV_ROOT_TOKEN_ID: "root")
      @token = "root"
      puts "starting container"
      @container.start
      puts "waiting for container to be ready"
      @container.wait_for_http(container_port: 8200, path: "/v1/sys/health")

      @container.logs.each { |log_line|
        if log_line.match(/Unseal Key.*: (.+)/)
          @unseal_token = $1.strip
          break
        end
      }
    end

    def stop
      @container&.stop if @container&.running?
      @container&.remove
    end

    def address
      "http://#{@container.host}:#{@container.mapped_port(8200)}"
    end

  end
end
