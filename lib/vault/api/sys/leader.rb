require_relative "../sys"

module Vault
  class LeaderStatus < Response.new(:ha_enabled, :is_self, :leader_address)
    alias_method :ha_enabled?, :ha_enabled
    alias_method :ha?, :ha_enabled
    alias_method :is_self?, :is_self
    alias_method :is_leader?, :is_self
    alias_method :leader?, :is_self
    alias_method :address, :leader_address
  end

  class Sys
    # Determine the leader status for this vault.
    #
    # @example
    #   Vault.sys.leader #=> #<Vault::LeaderStatus ha_enabled=false, is_self=false, leader_address="">
    #
    # @return [LeaderStatus]
    def leader
      json = client.get("/v1/sys/leader")
      return LeaderStatus.decode(json)
    end
  end
end
