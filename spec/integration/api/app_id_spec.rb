require "spec_helper"

$APP_ID = "foo"
$USER_ID = "bar"

# Enable app-id authentication backend
vault_test_client.sys.enable_auth('app-id', 'app-id', nil)

# Configure App ID and User ID assocaited with the root policy
vault_test_client.logical.write("auth/app-id/map/app-id/#{$APP_ID}", "value":"root", "display_name":$APP_ID)
vault_test_client.logical.write("auth/app-id/map/user-id/#{$USER_ID}", "value":$APP_ID)

module Vault
  describe AppId do
    subject { vault_test_client.app_id }

    describe "#login" do
      it "creates a new client token" do
        result = subject.login("app_id":$APP_ID, "user_id":$USER_ID)
        expect(result).to be_a(Vault::Secret)
        expect(result.auth).to be_a(Vault::SecretAuth)
        expect(result.auth.client_token).to be
      end
    end
  end
end
