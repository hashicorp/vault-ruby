require "open-uri"
require "singleton"
require "timeout"
require "tempfile"
require "tmpdir"
require "testcontainers"

module RSpec
  class VaultServer
    include Singleton

    def self.method_missing(m, *args, &block)
      self.instance.public_send(m, *args, &block)
    end

    attr_reader :token
    attr_reader :unseal_token

    def initialize(vault_version = nil)
      if vault_version == nil
        env_version = ENV["VAULT_VERSION"]
        if env_version == nil
          vault_version = "latest"
        else
          vault_version = env_version
        end
      end

      dir = Dir.mktmpdir("vault-ruby-tests-")
      at_exit { FileUtils.remove_entry(dir) }
      fs_binds = { dir => "/tmp" }
      @container = Testcontainers::DockerContainer
                     .new("hashicorp/vault:#{vault_version}")
                     .with_exposed_port(8200)
                     .with_env(VAULT_DEV_ROOT_TOKEN_ID: "root")
                     .with_filesystem_binds(fs_binds)
      @token = "root"
      puts "starting container"
      @container.start
      puts "waiting for container to be ready"
      @container.wait_for_http(container_port: 8200, path: "/v1/sys/health")
      puts "container ready!"
      # we need to wait to get the unseal token
      sleep(5)

      got_unseal_token = false
      @container.logs.each { |log_line|
        if log_line.match(/Unseal Key.*: (.+)/)
          @unseal_token = $1.strip
          got_unseal_token = true
          break
        end
      }

      unless got_unseal_token
        raise "could not get unseal token from vault"
      end
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
