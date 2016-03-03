require 'webrick'
require 'uri'

module RSpec
  class RedirectServer < WEBrick::HTTPServlet::AbstractServlet
    def service(req, res)
      res['Location'] = URI.join(VaultServer.address, req.path)
      raise WEBrick::HTTPStatus[307]
    end

    def self.address
      'http://127.0.0.1:8201/'
    end

    def self.start
      @server ||= begin
                    server = WEBrick::HTTPServer.new(
                      Port: 8201,
                      Logger: WEBrick::Log.new("/dev/null"),
                      AccessLogs: [],
                    )
                    server.mount '/', self
                    at_exit { server.shutdown }
                    Thread.new { server.start }
                    server
                  end
    end
  end
end
