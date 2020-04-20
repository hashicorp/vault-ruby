module Vault
  class Sys
    def create_namespace(namespace, opts = {})
      json = client.put("/v1/sys/namespaces/#{namespace}", JSON.fast_generate(opts))
      return true
    end
  end
end
