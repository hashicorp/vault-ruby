module Vault
  class Sys
    def namespaces(scoped=nil)
      path = ["v1", scoped, "sys", "namespaces"].compact
      client.list(path.join("/"))
    end

    def create_namespace(namespace, opts = {})
      client.put("/v1/sys/namespaces/#{namespace}", JSON.fast_generate(opts))
      return true
    end

    def delete_namespace(namespace)
      client.delete("/v1/sys/namespaces/#{namespace}")
      return true
    end

    def namespace(namespace)
      json = client.get("/v1/sys/namespaces/#{namespace}")
      return json
    end
  end
end
