require "spec_helper"

module Vault
  describe Auth do
    subject { vault_test_client }

    describe "#token" do
      it "verifies the token and saves it on the client" do
        subject.auth.token(subject.token)
        expect(subject.token).to eq(subject.token)
      end

      it "raises an error if the token is invalid" do
        expect {
          expect {
            subject.auth.token("nope-not-real")
          }.to raise_error(HTTPError)
        }.to_not change(subject, :token)
      end
    end

    describe "#app_id" do
      before(:context) do
        @app_id  = "aeece56e-3f9b-40c3-8f85-781d3e9a8f68"
        @user_id = "3b87be76-95cf-493a-a61b-7d5fc70870ad"

        vault_test_client.sys.enable_auth("app-id", "app-id", nil)
        vault_test_client.logical.write("auth/app-id/map/app-id/#{@app_id}", { value: "root" })
        vault_test_client.logical.write("auth/app-id/map/user-id/#{@user_id}", { value: @app_id })

        vault_test_client.sys.enable_auth("new-app-id", "app-id", nil)
        vault_test_client.logical.write("auth/new-app-id/map/app-id/#{@app_id}", { value: "root" })
        vault_test_client.logical.write("auth/new-app-id/map/user-id/#{@user_id}", { value: @app_id })
      end

      it "authenticates and saves the token on the client" do
        result = subject.auth.app_id(@app_id, @user_id)
        expect(subject.token).to eq(result.auth.client_token)
      end

      it "authenticates with custom options" do
        result = subject.auth.app_id(@app_id, @user_id, mount: "new-app-id")
        expect(subject.token).to eq(result.auth.client_token)
      end

      it "raises an error if the authentication is bad" do
        expect {
          expect {
            subject.auth.app_id("nope", "bad")
          }.to raise_error(HTTPError)
        }.to_not change(subject, :token)
      end
    end

    describe "#userpass" do
      before(:context) do
        @username = "sethvargo"
        @password = "s3kr3t"

        vault_test_client.sys.enable_auth("userpass", "userpass", nil)
        vault_test_client.logical.write("auth/userpass/users/#{@username}", { password: @password, policies: "root" })

        vault_test_client.sys.enable_auth("new-userpass", "userpass", nil)
        vault_test_client.logical.write("auth/new-userpass/users/#{@username}", { password: @password, policies: "root" })
      end

      it "authenticates and saves the token on the client" do
        result = subject.auth.userpass(@username, @password)
        expect(subject.token).to eq(result.auth.client_token)
      end

      it "authenticates with custom options" do
        result = subject.auth.userpass(@username, @password, mount: "new-userpass")
        expect(subject.token).to eq(result.auth.client_token)
      end

      it "raises an error if the authentication is bad" do
        expect {
          expect {
            subject.auth.userpass("nope", "bad")
          }.to raise_error(HTTPError)
        }.to_not change(subject, :token)
      end
    end
  end
end
