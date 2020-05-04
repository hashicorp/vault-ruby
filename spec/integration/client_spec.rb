require "spec_helper"

module Vault
  describe Client do

    def free_address
      server = TCPServer.new("localhost", 0)
      address = ["localhost", server.addr[1]]
      server.close
      address
    end

    describe "#request" do
      it "raises HTTPConnectionError if it takes too long to read packets from the connection" do
        TCPServer.open('localhost', 0) do |server|
          Thread.new do
            loop do
              client = server.accept
              sleep 0.25
              client.close
            end
          end

          address = "http://%s:%s" % ["localhost", server.addr[1]]

          client = described_class.new(address: address, token: "foo", read_timeout: 0.01)

          expect {
            client.request(:get, "/", {}, {})
          }.to raise_error(HTTPConnectionError)

          server.close
        end
      end

      it "raises HTTPConnectionError if the port on the remote server is not open" do
        address = "http://%s:%s" % free_address

        client = described_class.new(address: address, token: "foo")

        expect { client.request(:get, "/", {}, {}) }.to raise_error(HTTPConnectionError)
      end

      it "raises an error when a token was missing" do
        client = Vault::Client.new(
          address: RSpec::VaultServer.address,
          token: nil,
        )

        expect {
          client.get("/v1/secret/password")
        }.to raise_error(MissingTokenError)
      end
    end

    describe "#shutdown" do
      it "clears the pool after calling shutdown and sets nhp to nil" do
        TCPServer.open('localhost', 0) do |server|
          Thread.new do
            loop do
              client = server.accept
              sleep 0.25
              client.close
            end
          end

          address = "http://%s:%s" % ["localhost", server.addr[1]]

          client = described_class.new(address: address, token: "foo")

          expect { client.request(:get, "/", {}, {}) }.to raise_error(HTTPConnectionError)

          pool = client.instance_variable_get(:@nhp).pool

          client.shutdown()

          expect(pool.available.instance_variable_get(:@enqueued)).to eq(0)
          expect(pool.available.instance_variable_get(:@shutdown_block)).not_to be_nil
          expect(client.instance_variable_get(:@nhp)).to be_nil

          server.close
        end
      end

      it "the pool is recreated on the following request" do
        TCPServer.open('localhost', 0) do |server|
          Thread.new do
            loop do
              client = server.accept
              sleep 0.25
              client.close
            end
          end

          address = "http://%s:%s" % ["localhost", server.addr[1]]

          client = described_class.new(address: address, token: "foo")

          expect { client.request(:get, "/", {}, {}) }.to raise_error(HTTPConnectionError)

          client.shutdown()

          expect { client.request(:get, "/", {}, {}) }.to raise_error(HTTPConnectionError)

          pool = client.instance_variable_get(:@nhp).pool

          expect(pool.available.instance_variable_get(:@enqueued)).to eq(1)
          expect(pool.available.instance_variable_get(:@shutdown_block)).to be_nil
          expect(client.instance_variable_get(:@nhp)).not_to be_nil

          server.close
        end
      end
    end

    describe "#request"do

      context "when using an enterprise vault version", ent_vault: ">= 0.13" do
        before(:context) do
          client = vault_test_client
          client.sys.create_namespace("bar")
          client.namespace = "bar"
          client.sys.create_namespace("baz")
          client.namespace = "bar/baz"

          next unless versioned_kv_by_default?

          client.sys.unmount("secret")
          client.sys.mount(
            "secret", "kv", "v1 KV", options: {version: "1"}
          )
        end

        after(:context) do
          client = vault_test_client
          client.namespace = "bar"
          client.sys.delete_namespace("baz")
          sleep 0.1
          client.namespace = nil
          client.sys.delete_namespace("bar")
          sleep 0.1

          next unless versioned_kv_by_default?

          client.sys.unmount("secret")
          client.sys.mount(
            "secret", "kv", "v2 KV", options: {version: "2"}
          )
        end

        context "when using a namespace" do
          subject { vault_test_client.tap{ |o| o.namespace = "bar/baz" } }

          it "should respect namespace boundaries" do
            subject.logical.write("secret/sekkrit", foo: "bar")
            subject.namespace = nil
            expect(subject.logical.read("secret/sekkrit")).to eq(nil)
            subject.namespace = "bar/baz"
            expect(subject.logical.read("secret/sekkrit").data).to eq(foo: "bar")
          end
        end

        context "when using a namespace as part of the request options" do
          subject { vault_test_client }

          it "should respect namespace boundaries" do
            subject.logical.write("secret/sekkrit", { foo: "bar" }, namespace: "bar/baz")
            expect(subject.logical.read("secret/sekkrit")).to eq(nil)
            expect(subject.logical.read("secret/sekkrit", namespace: "bar/baz").data).to eq(foo: "bar")
          end
        end
      end

      context "when using a non-enterprise version", non_ent_vault: ">= 0.13" do
        subject { vault_test_client }

        before(:context) do
          next unless versioned_kv_by_default?

          client = vault_test_client
          client.sys.unmount("secret")
          client.sys.mount(
            "secret", "kv", "v1 KV", options: {version: "1"}
          )
        end
      
        after(:context) do
          next unless versioned_kv_by_default?

          client = vault_test_client
          client.sys.unmount("secret")
          client.sys.mount(
            "secret", "kv", "v2 KV", options: {version: "2"}
          )
        end

        context "when a namespace is provided" do
          it "ignores the namespace" do
            subject.logical.write("secret/sekkrit", foo: "bar")  
            subject.namespace = "foo"
            expect(subject.logical.read("secret/sekkrit").data).to eq(foo: "bar")
          end
        end
      end
    end
  end
end
