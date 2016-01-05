require "spec_helper"

module Vault
  describe AuthToken do
    subject { vault_test_client.auth_token }

    describe "#create" do
      it "creates a new token" do
        result = subject.create
        expect(result).to be_a(Vault::Secret)
        expect(result.auth).to be_a(Vault::SecretAuth)
        expect(result.auth.client_token).to be
      end
    end

    describe "#renew_self" do
      it "renew the callign token"
    end

    describe "#revoke_self" do
      it "revoke the callign token"
    end

    describe "#renew" do
      it "renews the auth"

      it "returns an error if the auth is not renewable"
    end

    describe "#revoke_orphan" do
      it "revokes all orphans"
    end

    describe "#revoke_prefix" do
      it "revokes all with the prefix"
    end

    describe "#revoke_tree" do
      it "revokes the tree"
    end
  end
end
