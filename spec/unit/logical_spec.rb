# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

require "spec_helper"

module Vault
  describe Logical do
    let(:client) { double("client") }
    subject { described_class.new(client) }

    describe "#read" do
      it "returns nil when client.get returns nil (HTTP 204 No Content)" do
        allow(client).to receive(:get).and_return(nil)

        result = subject.read("pki/ca")

        expect(result).to be_nil
      end

      it "returns a Secret when client.get returns data" do
        allow(client).to receive(:get).and_return({
          data: { foo: "bar" },
          lease_duration: 0,
          renewable: false
        })

        result = subject.read("secret/test")

        expect(result).to be_a(Secret)
        expect(result.data).to eq(foo: "bar")
      end

      it "returns nil when client.get raises HTTPError with 404" do
        allow(client).to receive(:get).and_raise(HTTPError.new("address", double(code: "404")))

        result = subject.read("secret/missing")

        expect(result).to be_nil
      end

      it "raises HTTPError for other error codes" do
        allow(client).to receive(:get).and_raise(HTTPError.new("address", double(code: "500")))

        expect {
          subject.read("secret/error")
        }.to raise_error(HTTPError)
      end
    end
  end
end
