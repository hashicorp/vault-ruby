require_relative "../client"
require_relative "../response"

module Vault
  # Help is the response from a help query.
  class Help < Response.new(:help, :see_also); end

  class Client
    # Gets help for the given path.
    #
    # @example
    #   Vault.help #=> #<Vault::Help help="..." see_also="...">
    #
    # @param [String] path
    #   the path to get help for
    #
    # @return [Help]
    def help(path)
      json = self.get("/v1/#{CGI.escape(path)}", help: 1)
      return Help.decode(json)
    end
  end
end
