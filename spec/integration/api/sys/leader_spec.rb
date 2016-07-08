require "spec_helper"

module Vault
  describe Sys do
    subject { vault_test_client.sys }

    describe "#leader" do
      it "returns leader information" do
        result = subject.leader
        expect(result).to be_a(LeaderStatus)
        expect(result.ha_enabled?).to be(false)
        expect(result.ha?).to be(false)
        expect(result.is_self?).to be(false)
        expect(result.is_leader?).to be(false)
        expect(result.leader?).to be(false)
        expect(result.address).to eq("")
      end
    end
  end
end
