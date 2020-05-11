require_relative '../../request'
require_relative '../../response'

module Vault
  class Transform < Request
    class Transformation < Response
      field :allowed_roles
      field :templates
      field :tweak_source
      field :type
    end

    def create_transformation(name, type:, template:, **opts)
      opts ||= {}
      opts[:type] = type
      opts[:template] = template
      client.post("/v1/transform/transformation/#{encode_path(name)}", JSON.fast_generate(opts))
      return true
    end

    def get_transformation(name)
      json = client.get("/v1/transform/transformation/#{encode_path(name)}")
      if data = json.dig(:data)
        Transformation.decode(data)
      else
        json
      end
    end

    def delete_transformation(name)
      client.delete("/v1/transform/transformation/#{encode_path(name)}")
      true
    end

    def transformations
      json = client.list("/v1/transform/transformation")
      if keys = json.dig(:data, :keys)
        keys
      else
        json
      end
    end
  end
end
