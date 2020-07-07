module Vault
  class Quota < Response
    field :name
    field :path
    field :type
  end

  class RateLimitQuota < Quota
    field :rate
    field :burst
  end

  class LeaseCountQuota < Quota
    field :counter
    field :max_leases
  end

  class Sys
    def quotas(type)
      path = generate_path(type)
      json = client.list(path)
      if data = json.dig(:data, :key_info)
        data.map do |item|
          type_class(type).decode(item)
        end
      else
        json
      end
    end

    def create_quota(type, name, opts={})
      path = generate_path(type, name)
      client.post(path, JSON.fast_generate(opts))
      return true
    end

    def delete_quota(type, name)
      path = generate_path(type, name)
      client.delete(path)
      return true
    end

    def get_quota(type, name)
      path = generate_path(type, name)
      response = client.get(path)
      if data = response[:data]
        type_class(type).decode(data)
      end
    end

    def get_config
      client.get("v1/sys/quotas/config")
    end

    private

    def generate_path(type, name=nil)
      verify_type(type)
      path = ["v1", "sys", "quotas", type, name].compact
      path.join("/")
    end

    def verify_type(type)
      return if ["rate-limit", "lease-count"].include?(type)
      raise ArgumentError, "type must be one of \"rate-limit\" or \"lease-count\""
    end

    def type_class(type)
      case type
      when "lease-count" then LeaseCountQuota
      when "rate-limit" then RateLimitQuota
      end
    end
  end
end
