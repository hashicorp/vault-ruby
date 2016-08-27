require "spec_helper"

module Vault
  describe Response do
    let(:response) do
      Class.new(Response) do
        field :foo
        field :bar, as: :baz?
      end
    end

    describe ".field" do
      it "answers to declared field" do
        expect(response.new.foo).to eq nil
      end

      it "answers to declared field via :as" do
        expect(response.new.baz?).to eq nil
      end

      it "does ot answer to undeclared fields" do
        expect { response.new.bar }.to raise_error(NoMethodError)
      end
    end

    describe "'.fields' "do
      it "returns all fields" do
        expect(response.fields.keys).to eq([:foo, :bar])
      end
    end

    describe "#to_h" do
      it "returns all fields as hash" do
        expect(response.new(foo: 1, bar: 2).to_h).to eq(foo: 1, bar: 2)
      end
    end
  end
end
