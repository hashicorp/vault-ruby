require "spec_helper"

module Vault
  describe Sys do
    subject { vault_test_client.sys }

    describe "#mounts" do
      it "lists the mounts" do
        expect(subject.mounts).to be
        sys = subject.mounts[:sys]
        expect(sys).to be_a(Mount)
        expect(sys.type).to eq("system")
        expect(sys.description).to include("system endpoints")
      end

      it "shows options for mounts" do
        skip unless has_options_for_mount?
        kv = subject.mounts[:secret]
        expect(kv).to be_a(Mount)
        expect(kv.type).to eq("kv")
        expect(kv.description).to eq("key/value secret storage")
        expect(kv.options).to eq(version: "2")
      end
    end

    describe "#mount" do
      it "gets the mount by name" do
        expect(subject.mount("test_mount", "aws")).to be(true)
        result = subject.mounts[:test_mount]
        expect(result).to be_a(Mount)
        expect(result.type).to eq("aws")
        expect(result.description).to eq("")
      end

      it "returns the options from a mount" do
        next unless has_options_for_mount?

        expect(subject.mount("kv_v2_mount", "kv", 'kv v2 mount', options: {version: "2"})).to be(true)
        result = subject.mounts[:kv_v2_mount]
        expect(result).to be_a(Mount)
        expect(result.type).to eq("kv")
        expect(result.description).to eq("kv v2 mount")
        expect(result.options).to eq(:version => "2")

        expect(subject.mount("kv_v1_mount", "kv", 'kv v1 mount', options: {version: "1"})).to be(true)
        result = subject.mounts[:kv_v1_mount]
        expect(result).to be_a(Mount)
        expect(result.type).to eq("kv")
        expect(result.description).to eq("kv v1 mount")
        expect(result.options).to eq(:version => "1")
      end
    end

    describe "#mount_tune" do
      it "tunes the mount" do
        expect(subject.mount("test_mount_tune", "aws")).to be(true)
        expect(subject.mount_tune("test_mount_tune", max_lease_ttl: '1234h'))
        result = subject.mounts[:test_mount_tune]
        expect(result).to be_a(Mount)
        expect(result.config[:max_lease_ttl]).to eq(1234*60*60)
      end
    end

    describe "#unmount" do
      it "unmounts by name" do
        subject.mount("test_unmount", "aws")
        expect(subject.unmount("test_unmount")).to be(true)
      end
    end

    describe "#remount" do
      it "remounts at the new path" do
        subject.mount("test_remount", "aws")
        subject.remount("test_remount", "new_test_remount")
        expect(subject.mounts[:test_remount]).to be(nil)
        expect(subject.mounts[:new_test_remount]).to be
      end
    end
  end
end
