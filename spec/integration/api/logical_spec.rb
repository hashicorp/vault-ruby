require "spec_helper"

module Vault
  describe Logical do
    subject { vault_test_client.logical }

    describe "#list" do
      it "returns the empty array when no items exist" do
        expect(subject.list("secret/that/never/existed")).to eq([])
      end

      it "returns all secrets" do
        subject.write("secret/test-list-1", foo: "bar")
        subject.write("secret/test-list-2", foo: "bar")
        secrets = subject.list("secret")
        expect(secrets).to be_a(Array)
        expect(secrets).to include("test-list-1")
        expect(secrets).to include("test-list-2")
      end
    end

    describe "#read" do
      it "returns nil with the thing does not exist" do
        expect(subject.read("secret/foo/bar/zip")).to be(nil)
      end

      it "returns the secret when it exists" do
        subject.write("secret/test-read", foo: "bar")
        secret = subject.read("secret/test-read")
        expect(secret).to be
        expect(secret.data).to eq(foo: "bar")
      end

      it "allows special characters" do
        subject.write("secret/b:@c%n-read", foo: "bar")
        secret = subject.read("secret/b:@c%n-read")
        expect(secret).to be
        expect(secret.data).to eq(foo: "bar")
      end
    end

    describe "#write" do
      it "creates and returns the secret" do
        subject.write("secret/test-write", zip: "zap")
        result = subject.read("secret/test-write")
        expect(result).to be
        expect(result.data).to eq(zip: "zap")
      end

      it "overwrites existing secrets" do
        subject.write("secret/test-overwrite", zip: "zap")
        subject.write("secret/test-overwrite", bacon: true)
        result = subject.read("secret/test-overwrite")
        expect(result).to be
        expect(result.data).to eq(bacon: true)
      end

      it "allows special characters" do
        subject.write("secret/b:@c%n-write", foo: "bar")
        subject.write("secret/b:@c%n-write", bacon: true)
        secret = subject.read("secret/b:@c%n-write")
        expect(secret).to be
        expect(secret.data).to eq(bacon: true)
      end
    end

    describe "#delete" do
      it "deletes the secret" do
        subject.write("secret/delete", foo: "bar")
        expect(subject.delete("secret/delete")).to be(true)
        expect(subject.read("secret/delete")).to be(nil)
      end

      it "allows special characters" do
        subject.write("secret/b:@c%n-delete", foo: "bar")
        expect(subject.delete("secret/b:@c%n-delete")).to be(true)
        expect(subject.read("secret/b:@c%n-delete")).to be(nil)
      end

      it "does not error if the secret does not exist" do
        expect {
          subject.delete("secret/delete")
          subject.delete("secret/delete")
          subject.delete("secret/delete")
        }.to_not raise_error
      end
    end

    describe "#unwrap" do
      it "preserves the original access token" do
        original_token = Vault.token
        expect { subject.unwrap('some token')}.to raise_error
        expect(Vault.token).to eq(original_token)
      end

      it "returns the wrapped secret when it exists" do
        original_token = vault_test_client.token
        subject.write("secret/test-read", foo: "bar")
        expect(subject.read("secret/test-read").data).to eq(foo: "bar")

        expect {
          wrapped_token_response = vault_test_client.auth_token.create({"display_name" => "", "num_uses" => 0, "renewable" => true, :wrap_ttl => 500})
          unwrapped_token_response = subject.unwrap(wrapped_token_response.wrap_info.token)
          # Verify quality of unwrapped token response
          vault_test_client.token = unwrapped_token_response.data.auth.client_token
          expect(subject.read("secret/test-read").data).to eq(foo: "bar")
        }.to_not raise_error
        vault_test_client.token = original_token
      end
    end

    describe "#unwrap_token" do
      it "preserves the original access token" do
        original_token = Vault.token
        expect { subject.unwrap_token('some token')}.to raise_error
        expect(Vault.token).to eq(original_token)
      end

      it "returns the wrapped token (as a string) when it exists" do
        original_token = vault_test_client.token
        subject.write("secret/test-read", foo: "bar")
        expect(subject.read("secret/test-read").data).to eq(foo: "bar")

        expect {
          wrapped_token_response = vault_test_client.auth_token.create({"display_name" => "", "num_uses" => 0, "renewable" => true, :wrap_ttl => 500})
          vault_test_client.token = subject.unwrap_token(wrapped_token_response.wrap_info.token)
          expect(subject.read("secret/test-read").data).to eq(foo: "bar")
        }.to_not raise_error
        vault_test_client.token = original_token
      end

      it "returns the wrapped token (as a Vault::Secret) when it exists" do
        original_token = vault_test_client.token
        subject.write("secret/test-read", foo: "bar")
        expect(subject.read("secret/test-read").data).to eq(foo: "bar")

        expect {
          wrapped_token_response = vault_test_client.auth_token.create({"display_name" => "", "num_uses" => 0, "renewable" => true, :wrap_ttl => 500})
          vault_test_client.token = subject.unwrap_token(wrapped_token_response)
          expect(subject.read("secret/test-read").data).to eq(foo: "bar")
        }.to_not raise_error
        vault_test_client.token = original_token
      end

    end

  end
end
