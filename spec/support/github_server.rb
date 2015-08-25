require "open-uri"
require "singleton"

module RSpec
  class GithubServer
    include Singleton

    def self.method_missing(m, *args, &block)
      self.instance.public_send(m, *args, &block)
    end

    def initialize

      io = Tempfile.new("github-server")
      pid = Process.spawn({}, "#{File.dirname(__FILE__)}/github_stub_server.rb", out: io.to_i, err: io.to_i)

      at_exit do
        Process.kill("INT", pid)
        Process.waitpid2(pid)

        io.close
        io.unlink
      end
      wait_for_ready
    end

    def wait_for_ready
      sleep 1
    end
  end
end
