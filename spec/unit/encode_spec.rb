# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

require "spec_helper"

module Vault
  describe EncodePath do
    describe "#encode_path" do
      it "does not encode alphanumeric characters" do
        expect(EncodePath.encode_path("abcXYZ123")).to eq("abcXYZ123")
      end

      it "does not encode hyphens" do
        expect(EncodePath.encode_path("lookup-self")).to eq("lookup-self")
        expect(EncodePath.encode_path("auth/token/lookup-self")).to eq("auth/token/lookup-self")
      end

      it "does not encode underscores" do
        expect(EncodePath.encode_path("my_secret")).to eq("my_secret")
      end

      it "does not encode periods" do
        expect(EncodePath.encode_path("file.txt")).to eq("file.txt")
      end

      it "does not encode forward slashes" do
        expect(EncodePath.encode_path("a/b/c")).to eq("a/b/c")
      end

      it "encodes spaces as %20" do
        expect(EncodePath.encode_path("my secret")).to eq("my%20secret")
      end

      it "encodes special characters" do
        expect(EncodePath.encode_path("test@example")).to eq("test%40example")
        expect(EncodePath.encode_path("key=value")).to eq("key%3Dvalue")
        expect(EncodePath.encode_path("a&b")).to eq("a%26b")
      end

      it "encodes colons" do
        expect(EncodePath.encode_path("foo:bar")).to eq("foo%3Abar")
      end

      it "encodes tildes" do
        expect(EncodePath.encode_path("test~value")).to eq("test%7Evalue")
      end

      it "encodes unicode characters" do
        expect(EncodePath.encode_path("caf\u00e9")).to eq("caf%C3%A9")
      end

      it "handles empty strings" do
        expect(EncodePath.encode_path("")).to eq("")
      end

      it "handles paths with multiple encoded segments" do
        expect(EncodePath.encode_path("secret/my secret/sub path")).to eq("secret/my%20secret/sub%20path")
      end

      it "handles Vault auth paths correctly" do
        expect(EncodePath.encode_path("auth/token/lookup-self")).to eq("auth/token/lookup-self")
        expect(EncodePath.encode_path("auth/token/renew-self")).to eq("auth/token/renew-self")
        expect(EncodePath.encode_path("sys/mounts/secret-store")).to eq("sys/mounts/secret-store")
      end
    end
  end
end
