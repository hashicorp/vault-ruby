require "spec_helper"

describe Vault do
  it "sets the default values" do
    Vault::Configurable.keys.each do |key|
      value = Vault::Defaults.send(key)
      expect(Vault.instance_variable_get(:"@#{key}")).to eq(value)
    end
  end

  describe ".client" do
    it "creates an Vault::Client" do
      expect(Vault.client).to be_a(Vault::Client)
    end

    it "caches the client when the same options are passed" do
      expect(Vault.client).to eq(Vault.client)
    end

    it "returns a fresh client when options are not the same" do
      original_client = Vault.client

      # Change settings
      Vault.address = "http://new.address"
      new_client = Vault.client

      # Get it one more tmie
      current_client = Vault.client

      expect(original_client).to_not eq(new_client)
      expect(new_client).to eq(current_client)
    end
  end

  describe ".configure" do
    Vault::Configurable.keys.each do |key|
      it "sets the #{key.to_s.gsub("_", " ")}" do
        Vault.configure do |config|
          config.send("#{key}=", key)
        end

        expect(Vault.instance_variable_get(:"@#{key}")).to eq(key)
      end
    end
  end

  describe ".method_missing" do
    context "when the client responds to the method" do
      let(:client) { double(:client) }
      before { allow(Vault).to receive(:client).and_return(client) }

      it "delegates the method to the client" do
        allow(client).to receive(:bacon).and_return("awesome")
        expect { Vault.bacon }.to_not raise_error
      end
    end

    context "when the client does not respond to the method" do
      it "calls super" do
        expect { Vault.bacon }.to raise_error(NoMethodError)
      end
    end
  end

  describe ".respond_to_missing?" do
    let(:client) { double(:client) }
    before { allow(Vault).to receive(:client).and_return(client) }

    it "delegates to the client" do
      expect { Vault.respond_to_missing?(:foo) }.to_not raise_error
    end
  end
end
