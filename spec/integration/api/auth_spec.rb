require "spec_helper"

module Vault
  describe Auth do
    subject { vault_test_client }

    describe "#token" do
      before do
        subject.token = nil
      end

      it "verifies the token and saves it on the client" do
        token = RSpec::VaultServer.token
        subject.auth.token(token)
        expect(subject.token).to eq(token)
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

      before do
        subject.token = nil
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

      before do
        subject.token = nil
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

    describe "#tls" do
      before(:context) { vault_test_client.auth_tls.enable }
      after(:context) { vault_test_client.auth_tls.disable }

      let!(:old_token) { subject.token }
      let(:certificate) do
        Certificate.new(display_name: 'kaelumania-cert',
                        certificate: RSpec::SampleCertificate.cert,
                        policies: "default",
                        ttl: 3600)
      end

      before do
        allow(File).to receive(:read).with('kaelumania.pem') { RSpec::SampleCertificate.cert << RSpec::SampleCertificate.key }
      end

      after do
        subject.token = old_token
      end

      it "authenticates and saves the token on the client" do
        pending

        subject.auth_tls.put_certificate('kaelumania', certificate)

        result = subject.auth.tls('kaelumania.pem')
        expect(subject.token).to eq(result.auth.client_token)
      end

      it "authenticates with default ssl_pem_file" do
        pending

        subject.auth_tls.put_certificate('kaelumania', certificate)
        subject.ssl_pem_file = 'kaelumania.pem'

        result = subject.auth.tls
        expect(subject.token).to eq(result.auth.client_token)
      end

      it "raises an error if the authentication is bad" do
        expect {
          expect {
            subject.auth.tls('kaelumania.pem')
          }.to raise_error(HTTPError)
        }.to_not change(subject, :token)
      end
    end
  end
end
