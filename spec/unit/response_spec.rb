require "spec_helper"

module Vault
  describe "#to_h" do
    it "returns a hash" do
      instance = Class.new(Response) do
        field :a
        field :b, as: "c"
        field :d, load: ->(c) { "e" }
      end.new(
        a: "a",
        b: "b",
      )

      expect(instance.to_h).to eq({
          a: "a",
          b: "b",
          d: nil,
      })
    end

    it "returns a hash with nested values" do
      nested = Class.new(Response) do
        field :d
      end

      instance = Class.new(Response) do
        field :a, load: ->(v) { nested.new(d: v) }
      end.new(
        a: "a",
      )

      expect(instance.to_h).to eq({
        a: { d: "a" },
      })
    end
  end
end
