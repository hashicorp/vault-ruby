require "spec_helper"

require 'pry'

module Vault
  describe AuthTLS do
    subject { vault_test_client.auth_tls }

    before(:context) { vault_test_client.auth_tls.enable }
    after(:context) { vault_test_client.auth_tls.disable }

    describe "certificates" do
      let(:certificate) do
        Certificate.new(display_name: 'kaelumania-cert',
                        certificate: RSpec::SampleCertificate.cert,
                        policies: "default",
                        ttl: 3600) 
      end 

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
        expect(subject.put_certificate('kaelumania', certificate)).to be_truthy
        expect(subject.certificates).to include 'kaelumania'
      end
    end
  end
end
