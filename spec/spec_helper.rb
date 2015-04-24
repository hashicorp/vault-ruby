$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "vault"

require "pathname"

require_relative "support/vault_server"

RSpec.configure do |config|
  # Custom helper modules and extensions

  # Prohibit using the should syntax
  config.expect_with :rspec do |spec|
    spec.syntax = :expect
  end

  # Allow tests to isolate a specific test using +focus: true+. If nothing
  # is focused, then all tests are executed.
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true

  # Ensure our configuration is reset on each run.
  config.before(:each) { Vault.reset! }
  config.after(:each)  { Vault.reset! }

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

def tmp
  Pathname.new(File.expand_path("../tmp", __FILE__))
end
