# Copyright IBM Corp. 2015, 2025
# SPDX-License-Identifier: MPL-2.0

require "spec_helper"

module Vault
  describe Authenticate do
    let(:client) { double('client') }
    let(:auth) { Authenticate.new(client) }

    describe '#okta' do
      it 'authenticates with Okta auth method' do
        allow(client).to receive(:post).with('/v1/auth/okta/login/user1', {password: 'secure'}.to_json) { {auth: {client_token: 'abcd-1234'}} }
        allow(client).to receive(:token=)
        expect(auth.okta('user1', 'secure').auth.client_token).to eq('abcd-1234')
      end
    end

    describe "#region_from_sts_endpoint" do
      subject { auth.send(:region_from_sts_endpoint, sts_endpoint) }

      context 'with a china endpoint' do
        let(:sts_endpoint) { "https://sts.cn-north-1.amazonaws.com.cn" }
        it { is_expected.to eq 'cn-north-1' }
      end

      context 'with a GovCloud endpoint' do
        let(:sts_endpoint) { "https://sts.us-gov-west-1.amazonaws.com" }
        it { is_expected.to eq 'us-gov-west-1' }
      end

      context 'with a standard regional endpoint' do
        let(:sts_endpoint) { "https://sts.us-west-2.amazonaws.com" }
        it { is_expected.to eq 'us-west-2' }
      end

      context 'with no regional endpoint' do
        let(:sts_endpoint) { "https://sts.amazonaws.com" }
        it { is_expected.to eq 'us-east-1' }
      end

      context 'with a malformed url' do
        let(:sts_endpoint) { "https:sts.amazonaws.com" }
        it { expect { subject }.to raise_exception(StandardError, "Unable to parse STS endpoint https:sts.amazonaws.com") }
      end

      context 'with a potentially malicious url' do
        let(:sts_endpoint) { "https://stsXamazonaws.com" }
        it { expect {subject}.to raise_exception(StandardError, "Unable to parse STS endpoint https://stsXamazonaws.com") }
      end

      context 'with a host suffix attack' do
        let(:sts_endpoint) { 'https://sts.amazonaws.com.evil.example' }
        it { expect { subject }.to raise_exception(StandardError, 'Unable to parse STS endpoint https://sts.amazonaws.com.evil.example') }
      end

      context 'with a query string' do
        let(:sts_endpoint) { 'https://sts.us-west-2.amazonaws.com?foo=bar' }
        it { is_expected.to eq 'us-west-2' }
      end

      context 'with a non-root path' do
        let(:sts_endpoint) { 'https://sts.us-west-2.amazonaws.com/foo' }
        it { is_expected.to eq 'us-west-2' }
      end

      context 'with a non-default port' do
        let(:sts_endpoint) { 'https://sts.us-west-2.amazonaws.com:8443' }
        it { is_expected.to eq 'us-west-2' }
      end

      context 'with embedded user info' do
        let(:sts_endpoint) { 'https://user:pass@sts.us-west-2.amazonaws.com' }
        it { expect { subject }.to raise_exception(StandardError, 'Unable to parse STS endpoint https://user:pass@sts.us-west-2.amazonaws.com') }
      end
    end
  end
end
