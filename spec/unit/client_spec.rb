require "spec_helper"

module Vault
  describe Client do
    let(:client) { subject }

    context "configuration" do
      it "is a configurable object" do
        expect(client).to be_a(Configurable)
      end

      it "users the default configuration" do
        Defaults.options.each do |key, value|
          expect(client.send(key)).to eq(value)
        end
      end

      it "uses the values in the initializer" do
        client = described_class.new(address: "http://new.address")
        expect(client.address).to eq("http://new.address")
      end

      it "can be modified after initialization" do
        expect(client.address).to eq(Defaults.address)
        client.address = "http://new.address"
        expect(client.address).to eq("http://new.address")
      end
    end

    describe "#get" do
      it "delegates to the #request method" do
        expect(subject).to receive(:request).with(:get, "/foo", {}, {})
        subject.get("/foo")
      end
    end

    describe "#post" do
      let(:data) { double }

      it "delegates to the #request method" do
        expect(subject).to receive(:request).with(:post, "/foo", data, {})
        subject.post("/foo", data)
      end
    end

    describe "#put" do
      let(:data) { double }

      it "delegates to the #request method" do
        expect(subject).to receive(:request).with(:put, "/foo", data, {})
        subject.put("/foo", data)
      end
    end

    describe "#patch" do
      let(:data) { double }

      it "delegates to the #request method" do
        expect(subject).to receive(:request).with(:patch, "/foo", data, {})
        subject.patch("/foo", data)
      end
    end

    describe "#delete" do
      it "delegates to the #request method" do
        expect(subject).to receive(:request).with(:delete, "/foo", {}, {})
        subject.delete("/foo")
      end
    end

    describe "#to_query_string" do
      it "converts spaces to + characters" do
        params = { emoji: "sad panda" }
        expect(subject.to_query_string(params)).to eq("emoji=sad+panda")
      end
    end
  end
end
