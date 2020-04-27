$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "vault"

require "pathname"
require "webmock/rspec"

require_relative "support/vault_server"
require_relative "support/redirect_server"
require_relative "support/sample_certificate"

def vault_version_string
  @vault_version_string ||= `vault --version`
end

TEST_VAULT_VERSION = Gem::Version.new(vault_version_string.match(/(\d+\.\d+\.\d+)/)[1])

RSpec.configure do |config|
  # Custom helper modules and extensions

  # Prohibit using the should syntax
  config.expect_with :rspec do |spec|
    spec.syntax = :expect
  end

  # Allow tests to isolate a specific test using +focus: true+. If nothing
  # is focused, then all tests are executed.
  config.filter_run_when_matching :focus
  config.filter_run_excluding vault: lambda { |v|
    !vault_meets_requirements?(v)
  }
  config.filter_run_excluding ent_vault: lambda { |v|
    !vault_is_enterprise? || !vault_meets_requirements?(v)
  }
  config.filter_run_excluding non_ent_vault: lambda { |v|
    vault_is_enterprise? || !vault_meets_requirements?(v)
  }

  # Disable real connections.
  config.before(:suite) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  # Ensure our configuration is reset on each run.
  config.before(:each) { Vault.setup! }
  config.after(:each)  { Vault.setup! }

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

def tmp
  Pathname.new(File.expand_path("../tmp", __FILE__))
end

def vault_test_client
  Vault::Client.new(
    address: RSpec::VaultServer.address,
    token:   RSpec::VaultServer.token,
  )
end

def vault_redirect_test_client
  Vault::Client.new(
    address: RSpec::RedirectServer.address,
    token:   RSpec::VaultServer.token,
  )
end

def versioned_kv_by_default?
  vault_meets_requirements?(">= 0.10")
end

def vault_is_enterprise?
  !!vault_version_string.match(/\+(?:ent|prem)/)
end

def vault_meets_requirements?(v)
  Gem::Requirement.new(v).satisfied_by?(TEST_VAULT_VERSION)
end

def with_stubbed_env(env = {})
  old = ENV.to_hash
  env.each do |k,v|
    if v.nil?
      ENV.delete(k.to_s)
    else
      ENV[k.to_s] = v.to_s
    end
  end
  yield
ensure
  ENV.replace(old)
end
