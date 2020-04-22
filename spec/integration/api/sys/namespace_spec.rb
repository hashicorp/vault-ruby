require "spec_helper"

module Vault
  describe Sys, ent_vault: ">= 0.13" do
    subject { vault_test_client }

    describe "#namespaces" do
      it "lists the available namespaces" do
        subject.sys.create_namespace("foo")
        subject.sys.create_namespace("baz")
        
        keys = subject.sys.namespaces[:data][:keys]
        expect(keys).to include("foo/")
        expect(keys).to include("baz/")
        
        # Cleanup
        subject.sys.delete_namespace("foo")
        subject.sys.delete_namespace("baz")
        sleep 0.1
      end
      
      it "lists only nested namespaces if a namespace is provided" do
        subject.sys.create_namespace("foo")
        subject.sys.create_namespace("baz")

        subject.namespace = "foo"
        subject.sys.create_namespace("bar")

        keys = subject.sys.namespaces[:data][:keys]
        expect(keys).not_to include("baz/")
        expect(keys).to include("bar/")

        # Cleanup
        subject.sys.delete_namespace("bar")
        subject.namespace = nil
        subject.sys.delete_namespace("baz")
        sleep 0.1
        subject.sys.delete_namespace("foo")
        sleep 0.1
      end
    end

    describe "#namespace" do
      it "gives info on the namespace provided" do
        subject.sys.create_namespace("foo")
        expect(subject.sys.namespace("foo")[:data][:path]).to eq("foo/")

        # Cleanup
        subject.sys.delete_namespace("foo")
        sleep 0.1
      end
    end
  end
end
