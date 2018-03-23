# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vault/version"

Gem::Specification.new do |spec|
  spec.name          = "vault"
  spec.version       = Vault::VERSION
  spec.authors       = ["Seth Vargo"]
  spec.email         = ["sethvargo@gmail.com"]
  spec.licenses      = ["MPL-2.0"]

  spec.summary       = "Vault is a Ruby API client for interacting with a Vault server."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/hashicorp/vault-ruby"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "aws-sigv4"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake",    "~> 12.0"
  spec.add_development_dependency "rspec",   "~> 3.5"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "webmock", "~> 2.3"
end
