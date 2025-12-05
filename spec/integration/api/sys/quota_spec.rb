# Copyright IBM Corp. 2015, 2025
# SPDX-License-Identifier: MPL-2.0

require "spec_helper"

RSpec.shared_examples "quota specs" do |type|
  it "lists all #{type} quotas" do
    subject.sys.create_quota(type, "list_test_1", create_args)
    subject.sys.create_quota(type, "list_test_2", other_args)
    expect(subject.sys.quotas(type)[:data][:keys].count).to eq(2)
    subject.sys.delete_quota(type, "list_test_1")
    subject.sys.delete_quota(type, "list_test_2")
  end

  it "creates a #{type} quota" do
    subject.sys.create_quota(type, "test_1", create_args)
    expect(subject.sys.get_quota(type, "test_1").to_h).to include(create_args)
    subject.sys.delete_quota(type, "test_1")
  end

  it "deletes a #{type} quota" do
    subject.sys.create_quota(type, "test_1", create_args)
    subject.sys.delete_quota(type, "test_1")
    expect{ subject.sys.get_quota(type, "test_1") }.to raise_error(Vault::HTTPClientError, /404/)
  end

  it "raises an exception if the required parameters aren't supplied" do
    expect{ subject.sys.create_quota(type, "test_1", {}) }.to(
      raise_error(Vault::HTTPClientError, /400/)
    )
  end
end

module Vault
  describe Sys, vault: ">= 1.5" do
    subject { vault_test_client }
    it "raises an error if the type is not rate-limit or lease-count" do
      expect{ subject.sys.create_quota("foo-bar", "test_1", {}) }.to(
        raise_error(ArgumentError, /type must be one of/)
      )
    end

    context "with rate-limits" do
      let(:create_args) do
        {
          rate: 16.7,
        }
      end

      let(:other_args) do
        {
          rate: 10,
          burst: 1000,
          path: "secret",
        }
      end
      include_examples "quota specs", "rate-limit"
    end

    context "with lease-counts", ent_vault: ">= 1.5" do
      let(:create_args) do
        {
          max_leases: 3,
        }
      end

      let(:other_args) do
        {
          max_leases: 10,
          path: "secret",
        }
      end
      include_examples "quota specs", "lease-count"
    end

    context "for quota configuration" do
      it "allows you to set and retrieve quota configs" do
        expect(subject.sys.get_quota_config[:data])
          .to include(enable_rate_limit_audit_logging: false)
        subject.sys.update_quota_config(enable_rate_limit_audit_logging: true)
        expect(subject.sys.get_quota_config[:data])
          .to include(enable_rate_limit_audit_logging: true)
        subject.sys.update_quota_config(enable_rate_limit_audit_logging: false)
      end

      it "performs a no-op for a bad input" do
        expect(subject.sys.get_quota_config[:data]).to include(enable_rate_limit_audit_logging: false)
        subject.sys.update_quota_config(foo: "bar")
        expect(subject.sys.get_quota_config[:data]).to include(enable_rate_limit_audit_logging: false)
      end
    end
  end
end
