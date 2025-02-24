# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vault/version"

Gem::Specification.new do |spec|
  spec.name          = "vault"
  spec.version       = Vault::VERSION
  spec.authors       = ["Seth Vargo"]
  spec.email         = ["team-vault-devex@hashicorp.com"]
  spec.licenses      = ["MPL-2.0"]

  spec.summary       = "Vault is a Ruby API client for interacting with a Vault server."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/hashicorp/vault-ruby"

  spec.files         = Dir["lib/**/**/**"]
  spec.files        += ["README.md", "CHANGELOG.md", "LICENSE"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.1"
  spec.add_runtime_dependency "aws-sigv4"
  spec.add_runtime_dependency "base64"
  spec.add_runtime_dependency "connection_pool",     "~> 2.4"
  spec.add_runtime_dependency "net-http-persistent", "~> 4.0", ">= 4.0.2"

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "pry",     "~> 0.13.1"
  spec.add_development_dependency "rake",    "~> 12.0"
  spec.add_development_dependency "rspec",   "~> 3.5"
  spec.add_development_dependency "yard",    "~> 0.9.24"
  spec.add_development_dependency "webmock", "~> 3.8.3"
  spec.add_development_dependency "webrick", "~> 1.5"
end
