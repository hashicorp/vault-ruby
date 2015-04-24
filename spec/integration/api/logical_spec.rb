require "spec_helper"

module Vault
  describe Logical do
    subject { vault_test_client.logical }

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
    end

    describe "#write" do
      it "creates and returns the secret" do
        result = subject.write("secret/test-write", zip: "zap")
        expect(result).to be
        expect(result.data).to eq(zip: "zap")
      end

      it "overwrites existing secrets" do
        subject.write("secret/test-overwrite", zip: "zap")
        result = subject.write("secret/test-overwrite", bacon: true)
        expect(result).to be
        expect(result.data).to eq(bacon: true)
      end
    end

    describe "#delete" do
      it "deletes the secret" do
        subject.write("secret/delete", foo: "bar")
        expect(subject.delete("secret/delete")).to be(true)
        expect(subject.read("secret/delete")).to be(nil)
      end

      it "does not error if the secret does not exist" do
        expect {
          subject.delete("secret/delete")
          subject.delete("secret/delete")
          subject.delete("secret/delete")
        }.to_not raise_error
      end
    end
  end
end
