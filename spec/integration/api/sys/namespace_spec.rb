require "spec_helper"

module Vault
  describe Sys, ent_vault: ">= 0.13" do
    subject { vault_test_client }

    describe "#namespaces" do
      it "lists the available namespaces" do
        subject.sys.create_namespace("foo")
        subject.sys.create_namespace("baz")
        
        keys = subject.sys.namespaces.keys
        expect(keys).to include(:foo)
        expect(keys).to include(:baz)
        
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
        subject.sys.create_namespace("bardle")

        namespaces = subject.sys.namespaces
        expect(namespaces.keys).not_to include(:baz)
        expect(namespaces.keys).to include(:bar)
        expect(namespaces[:bar].path).to eq("foo/bar/")
        expect(namespaces.keys).to include(:bardle)
        expect(namespaces[:bardle].path).to eq("foo/bardle/")

        # Cleanup
        subject.sys.delete_namespace("bar")
        subject.sys.delete_namespace("bardle")
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
        expect(subject.sys.get_namespace("foo").path).to eq("foo/")

        # Cleanup
        subject.sys.delete_namespace("foo")
        sleep 0.1
      end

      it "gives info on the nested namespaces if one is provided" do
        subject.sys.create_namespace("foo")
        subject.namespace = "foo"
        subject.sys.create_namespace("bar")
        expect(subject.sys.get_namespace("bar").path).to eq("foo/bar/")

        # Cleanup
        subject.sys.delete_namespace("bar")
        sleep 0.1
        subject.namespace = nil
        subject.sys.delete_namespace("foo")
        sleep 0.1
      end
    end
  end
end
