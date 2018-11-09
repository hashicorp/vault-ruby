require "spec_helper"

module Vault
  describe Client do

    def redirected_client
      Vault::Client.new(address: RSpec::RedirectServer.address, token: RSpec::VaultServer.token)
    end

    before do
      RSpec::RedirectServer.start
    end

    describe "#request" do
      it "handles redirections properly in GET requests" do
        expect(redirected_client.get("/v1/sys/policy")[:policies]).to include('root')
      end

      it "handles redirections properly in PUT requests" do
        redirected_client.post("/v1/secret/data/redirect", { data: { works: true } }.to_json)
        expect(vault_test_client.versioned_logical.read('secret', 'redirect').data[:works]).to eq(true)
      end

      it "handles redirections properly in DELETE requests" do
        vault_test_client.versioned_logical.write('secret', 'redirect', { deleted: false })
        redirected_client.delete("/v1/secret/data/redirect")
        expect(vault_test_client.versioned_logical.read('secret', 'redirect')).to be_nil
      end

      it "handles redirections properly in POST requests" do
        data = redirected_client.post("/v1/auth/token/create", "{}")
        expect(data).to include(:auth)
      end
    end
  end
end
