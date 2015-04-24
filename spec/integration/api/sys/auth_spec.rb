require "spec_helper"

module Vault
  describe Sys do
    subject { vault_test_client.sys }

    describe "#auths" do
      it "returns the list of auths" do
        expect(subject.auths).to be
      end
    end

    describe "#enable_auth" do
      it "enables the auth" do
        expect(subject.enable_auth("enable_auth", "github")).to be(true)
        expect(subject.auths[:enable_auth]).to be
      end
    end

    describe "#disable_auth" do
      it "disables the auth" do
        subject.enable_auth("disable_auth", "github")
        expect(subject.disable_auth("disable_auth")).to be(true)
      end
    end
  end
end
