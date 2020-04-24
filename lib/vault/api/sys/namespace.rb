module Vault
  class Namespace < Response
    field :id
    field :path
  end

  class Sys
    def namespaces(scoped=nil)
      path = ["v1", scoped, "sys", "namespaces"].compact
      json = client.list(path.join("/"))
      json = json[:data] if json[:data]
      json = json[:key_info] if json[:key_info]
      return Hash[*json.map do |k,v|
        [k.to_s.chomp("/").to_sym, Namespace.decode(v)]
      end.flatten]
    end

    def create_namespace(namespace, opts = {})
      client.put("/v1/sys/namespaces/#{namespace}", JSON.fast_generate(opts))
      return true
    end

    def delete_namespace(namespace)
      client.delete("/v1/sys/namespaces/#{namespace}")
      return true
    end

    def get_namespace(namespace)
      json = client.get("/v1/sys/namespaces/#{namespace}")
      json = json[:data] if json[:data]
      json = json[:key_info] if json[:key_info]
      Namespace.decode(json)
    end
  end
end
