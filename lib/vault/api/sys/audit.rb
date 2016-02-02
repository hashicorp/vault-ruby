require "json"

require_relative "../sys"

module Vault
  class Audit < Response.new(:type, :description, :options); end

  class Sys
    # List all audis for the vault.
    #
    # @example
    #   Vault.sys.audits #=> { :file => #<Audit> }
    #
    # @return [Hash<Symbol, Audit>]
    def audits
      json = client.get("/v1/sys/audit")
      return Hash[*json.map do |k,v|
        [k.to_s.chomp("/").to_sym, Audit.decode(v)]
      end.flatten]
    end

    # Enable a particular audit. Note: the +options+ depend heavily on the
    # type of audit being enabled. Please refer to audit-specific documentation
    # for which need to be enabled.
    #
    # @example
    #   Vault.sys.enable_audit("/file-audit", "file", "File audit", path: "/path/on/disk") #=> true
    #
    # @param [String] path
    #   the path to mount the audit
    # @param [String] type
    #   the type of audit to enable
    # @param [String] description
    #   a human-friendly description of the audit backend
    # @param [Hash] options
    #   audit-specific options
    #
    # @return [true]
    def enable_audit(path, type, description, options = {})
      client.put("/v1/sys/audit/#{CGI.escape(path)}", JSON.fast_generate(
        type:        type,
        description: description,
        options:     options,
      ))
      return true
    end

    # Disable a particular audit. If an audit does not exist, and error will be
    # raised.
    #
    # @param [String] path
    #   the path of the audit to disable
    #
    # @return [true]
    def disable_audit(path)
      client.delete("/v1/sys/audit/#{CGI.escape(path)}")
      return true
    end
  end
end
