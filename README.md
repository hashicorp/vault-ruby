Vault Ruby Client [![Build Status](https://secure.travis-ci.org/hashicorp/vault-ruby.svg)](http://travis-ci.org/hashicorp/vault-ruby)
=================

Vault is the official Ruby client for interacting with [Vault](https://vaultproject.io) by HashiCorp.

**The documentation in this README corresponds to the master branch of the Vault Ruby client. It may contain unreleased features or different APIs than the most recently released version. Please see the Git tag that corresponds to your version of the Vault Ruby client for the proper documentation.**

Quick Start
-----------
Install Ruby 2.0+: [Guide](https://www.ruby-lang.org/en/documentation/installation/).

> Please note that Vault Ruby may work on older Ruby installations like Ruby 1.9, but you **should not** use these versions of Ruby when communicating with a Vault server. Ruby 1.9 has [reached EOL](https://www.ruby-lang.org/en/news/2014/01/10/ruby-1-9-3-will-end-on-2015/) and will no longer receive important security patches or maintenance updates. There _are known security vulnerabilities_ specifically around SSL ciphers, which this library uses to communicate with a Vault server. While many distros still ship with Ruby 1.9 as the default, you are **highly discouraged** from using this library on any version of Ruby lower than Ruby 2.0.

Install via Rubygems:

    $ gem install vault

or add it to your Gemfile if you're using Bundler:

```ruby
gem "vault", "~> 0.1"
```

and then run the `bundle` command to install.

Start a Vault client:

```ruby
Vault.address = "http://127.0.0.1:8200" # Also reads from ENV["VAULT_ADDR"]
Vault.token   = "abcd-1234" # Also reads from ENV["VAULT_TOKEN"]

Vault.sys.mounts #=> { :secret => #<struct Vault::Mount type="generic", description="generic secret storage"> }
```

Usage
-----
The following configuration options are available:

```ruby
Vault.configure do |config|
  # The address of the Vault server, also read as ENV["VAULT_ADDR"]
  config.address = "https://127.0.0.1:8200"

  # The token to authenticate with Vault, also read as ENV["VAULT_TOKEN"]
  config.token = "abcd-1234"

  # Proxy connection information, also read as ENV["VAULT_PROXY_(thing)"]
  config.proxy_address  = "..."
  config.proxy_port     = "..."
  config.proxy_username = "..."
  config.proxy_password = "..."

  # Custom SSL PEM, also read as ENV["VAULT_SSL_CERT"]
  config.ssl_pem_file = "/path/on/disk.pem"

  # Use SSL verification, also read as ENV["VAULT_SSL_VERIFY"]
  config.ssl_verify = false

  # Timeout the connection after a certain amount of time (seconds), also read
  # as ENV["VAULT_TIMEOUT"]
  config.timeout = 30

  # It is also possible to have finer-grained controls over the timeouts, these
  # may also be read as environment variables
  config.ssl_timeout  = 5
  config.open_timeout = 5
  config.read_timeout = 30
end
```

If you do not want the Vault singleton, or if you need to communicate with multiple Vault servers at once, you can create independent client objects:

```ruby
client_1 = Vault::Client.new(address: "https://vault.mycompany.com")
client_2 = Vault::Client.new(address: "https://other-vault.mycompany.com")
```

### Making requests
All of the methods and API calls are heavily documented with examples inline using YARD. In order to keep the examples versioned with the code, the README only lists a few examples for using the Vault gem. Please see the inline documentation for the full API documentation. The tests in the 'spec' directory are an additional source of examples.

Idempotent requests can be wrapped with a `with_retries` clause to automatically retry on certain connection errors. For example, to retry on socket/network-level issues, you can do the following:

```ruby
Vault.with_retries(Vault::HTTPConnectionError) do
  Vault.logical.read("secret/on_bad_network")
end
```

To rescue particular HTTP exceptions:

```ruby
# Rescue 4xx errors
Vault.with_retries(Vault::HTTPClientError) {}

# Rescue 5xx errors
Vault.with_retries(Vault::HTTPServerError) {}

# Rescue all HTTP errors
Vault.with_retries(Vault::HTTPError) {}
```

For advanced users, the first argument of the block is the attempt number and the second argument is the exception itself:

```ruby
Vault.with_retries(Vault::HTTPConnectionError, Vault::HTTPError) do |attempt, e|
  log "Received exception #{e} from Vault - attempt #{attempt}"
  Vault.logical.read("secret/bacon")
end
```

The following options are available:

```ruby
# :attempts - The number of retries when communicating with the Vault server.
#   The default value is 2.
#
# :base - The base interval for retry exponential backoff. The default value is
#   0.05s.
#
# :max_wait - The maximum amount of time for a single exponential backoff to
#   sleep. The default value is 2.0s.

Vault.with_retries(Vault::HTTPError, attempts: 5) do
  # ...
end
```

After the number of retries have been exhausted, the original exception is raised.

```ruby
Vault.with_retries(Exception) do
  raise Exception
end #=> #<Exception>
```

#### Seal Status
```ruby
Vault.sys.seal_status
#=> #<Vault::SealStatus sealed=false, t=1, n=1, progress=0>
```

#### Create a Secret
```ruby
Vault.logical.write("secret/bacon", delicious: true, cooktime: "11")
#=> #<Vault::Secret lease_id="">
```

#### Retrieve a Secret
```ruby
Vault.logical.read("secret/bacon")
#=> #<Vault::Secret lease_id="">
```

#### Seal the Vault
```ruby
Vault.sys.seal #=> true
```

Development
-----------
1. Clone the project on GitHub
2. Create a feature branch
3. Submit a Pull Request

Important Notes:

- **All new features must include test coverage.** At a bare minimum, Unit tests are required. It is preferred if you include acceptance tests as well.
- **The tests must be be idempotent.** The HTTP calls made during a test should be able to be run over and over.
- **Tests are order independent.** The default RSpec configuration randomizes the test order, so this should not be a problem.
