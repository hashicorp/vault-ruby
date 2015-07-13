require "spec_helper"

module Vault
  describe Client do
    let(:client) { subject }

    describe ".timeout" do
      it "times out" do
        client.timeout = 1
        expect(client.get("http://google.com")).to eq("f")
      end
    end
  end
end
