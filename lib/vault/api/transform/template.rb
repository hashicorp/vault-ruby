require_relative '../../request'
require_relative '../../response'

module Vault
  class Transform < Request
    class Template < Response
      field :alphabet
      field :pattern
      field :type
    end

    def create_template(name, type:, pattern:, **opts)
      opts ||= {}
      opts[:type] = type
      opts[:pattern] = pattern
      client.post("/v1/transform/template/#{encode_path(name)}", JSON.fast_generate(opts))
      return true
    end

    def get_template(name)
      json = client.get("/v1/transform/template/#{encode_path(name)}")
      if data = json.dig(:data)
        Template.decode(data)
      else
        json
      end
    end

    def delete_template(name)
      client.delete("/v1/transform/template/#{encode_path(name)}")
      true
    end

    def templates
      json = client.list("/v1/transform/template")
      if keys = json.dig(:data, :keys)
        keys
      else
        json
      end
    end
  end
end
