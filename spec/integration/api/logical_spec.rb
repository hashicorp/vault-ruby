require "spec_helper"

module Vault
  module Logical
    describe Versioned, vault: ">= 0.10" do
      subject { vault_test_client.logical(:versioned) }

      describe "#list" do
        it "returns the empty array when no items exist" do
          expect(subject.list("secret", "that/never/existed")).to eq([])
        end

        it "returns all secrets" do
          subject.write("secret", "test-list-1", foo: "bar")
          subject.write("secret", "test-list-2", foo: "bar")
          secrets = subject.list("secret")
          expect(secrets).to be_a(Array)
          expect(secrets).to include("test-list-1")
          expect(secrets).to include("test-list-2")
        end
      end

      describe "#read" do
        it "returns nil with the thing does not exist" do
          expect(subject.read("secret", "foo/bar/zip")).to be(nil)
        end

        it "returns the secret when it exists" do
          subject.write("secret", "test-read", foo: "bar")
          secret = subject.read("secret", "test-read")
          expect(secret).to be
          expect(secret.data).to eq(foo: "bar")
        end

        it "allows special characters" do
          subject.write("secret", "b:@c%n-read", foo: "bar")
          secret = subject.read("secret", "b:@c%n-read")
          expect(secret).to be
          expect(secret.data).to eq(foo: "bar")
        end
      end

      describe "#write" do
        it "creates and returns the secret" do
          subject.write("secret", "test-write", zip: "zap")
          result = subject.read("secret", "test-write")
          expect(result).to be
          expect(result.data).to eq(zip: "zap")
        end

        it "overwrites existing secrets" do
          subject.write("secret", "test-overwrite", zip: "zap")
          subject.write("secret", "test-overwrite", bacon: true)
          result = subject.read("secret", "test-overwrite")
          expect(result).to be
          expect(result.data).to eq(bacon: true)
        end

        it "allows special characters" do
          subject.write("secret", "b:@c%n-write", foo: "bar")
          subject.write("secret", "b:@c%n-write", bacon: true)
          secret = subject.read("secret", "b:@c%n-write")
          expect(secret).to be
          expect(secret.data).to eq(bacon: true)
        end

        it "respects spaces properly" do
          key = 'sub/"Test Group"'
          subject.write("secret", key, foo: "bar")
          expect(subject.list("secret", "sub")).to eq(['"Test Group"'])
          secret = subject.read("secret", key)
          expect(secret).to be
          expect(secret.data).to eq(foo:"bar")
        end
      end

      describe "#delete" do
        it "deletes the secret" do
          subject.write("secret", "delete", foo: "bar")
          expect(subject.delete("secret", "delete")).to be(true)
          expect(subject.read("secret", "delete")).to be(nil)
        end

        it "allows special characters" do
          subject.write("secret", "b:@c%n-delete", foo: "bar")
          expect(subject.delete("secret", "b:@c%n-delete")).to be(true)
          expect(subject.read("secret", "b:@c%n-delete")).to be(nil)
        end

        it "does not error if the secret does not exist" do
          expect {
            subject.delete("secret", "delete")
            subject.delete("secret", "delete")
            subject.delete("secret", "delete")
          }.to_not raise_error
        end
      end

      describe "#unwrap", vault: ">= 0.6" do
        it "returns the wrapped secret when it exists" do
          wrapped = vault_test_client.auth_token.create(wrap_ttl: "5s")
          unwrapped = subject.unwrap(wrapped.wrap_info.token)

          expect(unwrapped.auth).to be
          expect(unwrapped.auth.client_token).to be

          vault_test_client.with_token(unwrapped.auth.client_token) do |client|
            expect { client.logical(:versioned).read("secret", "test") }.to_not raise_error
          end
        end
      end

      describe "#unwrap_token", vault: ">= 0.6" do
        it "returns the wrapped token when given a string" do
          wrapped = vault_test_client.auth_token.create(wrap_ttl: "5s")
          unwrapped = subject.unwrap_token(wrapped.wrap_info.token)

          expect(unwrapped).to be

          vault_test_client.with_token(unwrapped) do |client|
            expect { client.logical(:versioned).read("secret", "test") }.to_not raise_error
          end
        end

        it "returns the wrapped token when given a Vault::Secret" do
          wrapped = vault_test_client.auth_token.create(wrap_ttl: "5s")
          unwrapped = subject.unwrap_token(wrapped)

          expect(unwrapped).to be

          vault_test_client.with_token(unwrapped) do |client|
            expect { client.logical(:versioned).read("secret", "test") }.to_not raise_error
          end
        end

        it "returns nil when the response is empty" do
          token = vault_test_client.auth_token.create # Note no wrap-ttl here
          unwrapped = subject.unwrap_token(token.auth.client_token)
          expect(unwrapped).to be(nil)
        end
      end
    end

    describe Unversioned do
      subject { vault_test_client.logical(:unversioned) }

      def legacy?
        Gem::Requirement.new(">= 0.8").satisfied_by?(TEST_VAULT_VERSION)
      end

      let(:mount) { legacy? ? "legacy-secret" : "secret" }

      before(:context) do
        vault_test_client.sys.mount("legacy-secret", "kv", "", version: 1) if legacy?
      end

      after(:context) do
        vault_test_client.sys.unmount("legacy-secret") if legacy?
      end

      describe "#list" do
        it "returns the empty array when no items exist" do
          expect(subject.list("#{mount}/that/never/existed")).to eq([])
        end

        it "returns all secrets" do
          subject.write("#{mount}/test-list-1", foo: "bar")
          subject.write("#{mount}/test-list-2", foo: "bar")
          secrets = subject.list("#{mount}")
          expect(secrets).to be_a(Array)
          expect(secrets).to include("test-list-1")
          expect(secrets).to include("test-list-2")
        end
      end

      describe "#read" do
        it "returns nil with the thing does not exist" do
          expect(subject.read("#{mount}/foo/bar/zip")).to be(nil)
        end

        it "returns the secret when it exists" do
          subject.write("#{mount}/test-read", foo: "bar")
          secret = subject.read("#{mount}/test-read")
          expect(secret).to be
          expect(secret.data).to eq(foo: "bar")
        end

        it "allows special characters" do
          subject.write("#{mount}/b:@c%n-read", foo: "bar")
          secret = subject.read("#{mount}/b:@c%n-read")
          expect(secret).to be
          expect(secret.data).to eq(foo: "bar")
        end
      end

      describe "#write" do
        it "creates and returns the secret" do
          subject.write("#{mount}/test-write", zip: "zap")
          result = subject.read("#{mount}/test-write")
          expect(result).to be
          expect(result.data).to eq(zip: "zap")
        end

        it "overwrites existing secrets" do
          subject.write("#{mount}/test-overwrite", zip: "zap")
          subject.write("#{mount}/test-overwrite", bacon: true)
          result = subject.read("#{mount}/test-overwrite")
          expect(result).to be
          expect(result.data).to eq(bacon: true)
        end

        it "allows special characters" do
          subject.write("#{mount}/b:@c%n-write", foo: "bar")
          subject.write("#{mount}/b:@c%n-write", bacon: true)
          secret = subject.read("#{mount}/b:@c%n-write")
          expect(secret).to be
          expect(secret.data).to eq(bacon: true)
        end

        it "respects spaces properly" do
          key = "#{mount}/sub/\"Test Group\""
          subject.write(key, foo: "bar")
          expect(subject.list("#{mount}/sub")).to eq(['"Test Group"'])
          secret = subject.read(key)
          expect(secret).to be
          expect(secret.data).to eq(foo:"bar")
        end
      end

      describe "#delete" do
        it "deletes the secret" do
          subject.write("#{mount}/delete", foo: "bar")
          expect(subject.delete("#{mount}/delete")).to be(true)
          expect(subject.read("#{mount}/delete")).to be(nil)
        end

        it "allows special characters" do
          subject.write("#{mount}/b:@c%n-delete", foo: "bar")
          expect(subject.delete("#{mount}/b:@c%n-delete")).to be(true)
          expect(subject.read("#{mount}/b:@c%n-delete")).to be(nil)
        end

        it "does not error if the secret does not exist" do
          expect {
            subject.delete("#{mount}/delete")
            subject.delete("#{mount}/delete")
            subject.delete("#{mount}/delete")
          }.to_not raise_error
        end
      end

      describe "#unwrap", vault: ">= 0.6" do
        it "returns the wrapped secret when it exists" do
          wrapped = vault_test_client.auth_token.create(wrap_ttl: "5s")
          unwrapped = subject.unwrap(wrapped.wrap_info.token)

          expect(unwrapped.auth).to be
          expect(unwrapped.auth.client_token).to be

          vault_test_client.with_token(unwrapped.auth.client_token) do |client|
            expect { client.logical.read("#{mount}/test") }.to_not raise_error
          end
        end
      end

      describe "#unwrap_token", vault: ">= 0.6" do
        it "returns the wrapped token when given a string" do
          wrapped = vault_test_client.auth_token.create(wrap_ttl: "5s")
          unwrapped = subject.unwrap_token(wrapped.wrap_info.token)

          expect(unwrapped).to be

          vault_test_client.with_token(unwrapped) do |client|
            expect { client.logical.read("#{mount}/test") }.to_not raise_error
          end
        end

        it "returns the wrapped token when given a Vault::Secret" do
          wrapped = vault_test_client.auth_token.create(wrap_ttl: "5s")
          unwrapped = subject.unwrap_token(wrapped)

          expect(unwrapped).to be

          vault_test_client.with_token(unwrapped) do |client|
            expect { client.logical.read("#{mount}/test") }.to_not raise_error
          end
        end

        it "returns nil when the response is empty" do
          token = vault_test_client.auth_token.create # Note no wrap-ttl here
          unwrapped = subject.unwrap_token(token.auth.client_token)
          expect(unwrapped).to be(nil)
        end
      end
    end
  end
end
