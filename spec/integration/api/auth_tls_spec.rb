require "spec_helper"

require 'pry'

module Vault
  describe AuthTLS do
    subject { vault_test_client.auth_tls }

    before(:context) { vault_test_client.auth_tls.enable }
    after(:context) { vault_test_client.auth_tls.disable }

    describe "certificates" do
      let(:certificate) { Certificate.new('kaelumania-cert', RSpec::SampleCertificate.cert, "default", 3600) }

      it 'can be added' do
        expect(subject.put_certificate('kaelumania', certificate)).to be_truthy
        expect(subject.certificate('kaelumania')).to eq certificate
      end

      it 'can be deleted' do
        expect(subject.put_certificate('kaelumania', certificate)).to be_truthy
        expect(subject.delete_certificate('kaelumania')).to be_truthy
        expect(subject.certificate('kaelumania')).to be_nil
      end

      it 'can be listed' do
        pending

        expect(subject.put_certificate('kaelumania', certificate)).to be_truthy
        expect(subject.certificates).to include 'kaelumania'
      end
    end
  end
end
