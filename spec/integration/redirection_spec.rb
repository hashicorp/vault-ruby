require "spec_helper"

module Vault
  describe Client do

    def redirected_client
      Vault::Client.new(address: RSpec::RedirectServer.address, token: RSpec::VaultServer.token)
    end

    before do
      RSpec::RedirectServer.start
    end

    before(:context) do
      vault_test_client.sys.mount(
        "redirection", "kv", "v1 KV", options: {version: "1"}
      )
    end

    after(:context) do
      vault_test_client.sys.unmount("redirection")
    end

    describe "#request" do
      it "handles redirections properly in GET requests" do
        expect(redirected_client.get("/v1/sys/policy")[:policies]).to include('root')
      end

      it "handles redirections properly in PUT requests" do
        redirected_client.put("/v1/redirection/redirect", { works: true }.to_json)
        expect(vault_test_client.logical.read('redirection/redirect').data[:works]).to eq(true)
      end

      it "handles redirections properly in DELETE requests" do
        vault_test_client.logical.write('redirection/redirect', { deleted: false })
        redirected_client.delete("/v1/redirection/redirect")
        expect(vault_test_client.logical.read('redirection/redirect')).to be_nil
      end

      it "handles redirections properly in POST requests" do
        data = redirected_client.post("/v1/auth/token/create", "{}")
        expect(data).to include(:auth)
      end
    end
  end
end
