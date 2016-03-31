require "spec_helper"

module Vault
  describe AuthToken do
    subject { vault_test_client }

    describe "#create" do
      it "creates a new token" do
        result = subject.auth_token.create
        expect(result).to be_a(Vault::Secret)
        expect(result.auth).to be_a(Vault::SecretAuth)
        expect(result.auth.client_token).to be
      end
    end

    describe "#create_orphan" do
      it "creates an orphaned token" do
        result = subject.auth_token.create_orphan
        expect(result).to be_a(Vault::Secret)
        expect(result.auth).to be_a(Vault::SecretAuth)
        expect(result.auth.client_token).to be
      end
    end

    describe "#lookup" do
      it "retrieves the given token" do
        result = subject.auth_token.lookup(subject.token)
        expect(result).to be_a(Vault::Secret)
        expect(result.data[:id]).to eq(subject.token)
      end
    end

    describe "#lookup_self" do
      it "retrieves the current token" do
        result = subject.auth_token.lookup_self
        expect(result).to be_a(Vault::Secret)
        expect(result.data[:id]).to eq(subject.token)
      end
    end

    describe "#renew_self" do
      it "renews the calling token" do
        token = subject.auth_token.create(policies: ['default'])
        subject.auth.token(token.auth.client_token)
        result = subject.auth_token.renew_self
        expect(result).to be_a(Vault::Secret)
        expect(result.auth).to be_a(Vault::SecretAuth)
      end
    end

    describe "#revoke_self" do
      it "revokes the calling token" do
        token = subject.auth_token.create(policies: ['default'])
        subject.auth.token(token.auth.client_token)
        result = subject.auth_token.revoke_self
        expect(result).to be(nil)
      end
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
