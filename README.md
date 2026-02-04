Vault Ruby Client [![Build Status](https://github.com/hashicorp/vault-ruby/actions/workflows/run-tests.yml/badge.svg?branch=master)](https://github.com/hashicorp/vault-ruby/actions/workflows/run-tests.yml)
=================

Vault is the official Ruby client for interacting with [Vault](https://vaultproject.io) by HashiCorp.

**If you're viewing this README from GitHub on the `master` branch, know that it may contain unreleased features or
different APIs than the most recently released version. Please see the Git tag that corresponds to your version of the
Vault Ruby client for the proper documentation.**

Quick Start
-----------
Install Ruby 3.1+: [Guide](https://www.ruby-lang.org/en/documentation/installation/).

> Please note that as of Vault Ruby version 0.19.0, the minimum required Ruby version is 3.1. All EOL Ruby versions are no longer supported.

Install via Rubygems:

    $ gem install vault

or add it to your Gemfile if you're using Bundler:

```ruby
gem "vault"
```

and then run the `bundle` command to install.

Start a Vault client:

```ruby
Vault.address = "http://127.0.0.1:8200" # Also reads from ENV["VAULT_ADDR"]
Vault.token   = "abcd-1234" # Also reads from ENV["VAULT_TOKEN"]
# Optional - if using the Namespace enterprise feature
# Vault.namespace   = "my-namespace" # Also reads from ENV["VAULT_NAMESPACE"]

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
  # Optional - if using the Namespace enterprise feature
  # config.namespace   = "my-namespace" # Also reads from ENV["VAULT_NAMESPACE"]

  # Proxy connection information, also read as ENV["VAULT_PROXY_(thing)"]
  config.proxy_address  = "..."
  config.proxy_port     = "..."
  config.proxy_username = "..."
  config.proxy_password = "..."

  # Custom SSL PEM, also read as ENV["VAULT_SSL_CERT"]
  config.ssl_pem_file = "/path/on/disk.pem"

  # As an alternative to a pem file, you can provide the raw PEM string, also read in the following order of preference:
  # ENV["VAULT_SSL_PEM_CONTENTS_BASE64"] then ENV["VAULT_SSL_PEM_CONTENTS"]
  config.ssl_pem_contents = "-----BEGIN ENCRYPTED..."

  # Passphrase for encrypted PEM files
  config.ssl_pem_passphrase = "my-passphrase"

  # Custom SSL CA certificate for verification
  config.ssl_ca_cert = "/path/to/ca.crt"

  # Custom SSL CA certificate directory
  config.ssl_ca_path = "/path/to/ca/directory"

  # Custom SSL certificate store
  config.ssl_cert_store = OpenSSL::X509::Store.new

  # Specify SSL ciphers to use
  config.ssl_ciphers = "TLSv1.2:!aNULL:!eNULL"

  # Use SSL verification, also read as ENV["VAULT_SSL_VERIFY"]
  config.ssl_verify = false

  # SNI hostname to use for SSL connections
  config.hostname = "vault.example.com"

  # Timeout the connection after a certain amount of time (seconds), also read
  # as ENV["VAULT_TIMEOUT"]
  config.timeout = 30

  # It is also possible to have finer-grained controls over the timeouts, these
  # may also be read as environment variables
  config.ssl_timeout  = 5
  config.open_timeout = 5
  config.read_timeout = 30

  # Connection pool settings for persistent connections
  config.pool_size = 5
  config.pool_timeout = 5
end
```

If you do not want the Vault singleton, or if you need to communicate with multiple Vault servers at once, you can create independent client objects:

```ruby
client_1 = Vault::Client.new(address: "https://vault.mycompany.com")
client_2 = Vault::Client.new(address: "https://other-vault.mycompany.com")
```

### Authentication

Authenticate using various methods:

```ruby
# LDAP
Vault.auth.ldap("username", "password")

# Username/Password
Vault.auth.userpass("username", "password")

# AppRole
Vault.auth.approle("role_id", "secret_id")

# GitHub token
Vault.auth.github("github_token")

# AWS IAM
Vault.auth.aws_iam("role_name", credentials_provider, "header_value")
```

And if you want to authenticate with a `AWS EC2` :

```ruby
    # Export VAULT_ADDR to ENV then
    # Get the pkcs7 value from AWS
    signature = `curl http://169.254.169.254/latest/dynamic/instance-identity/pkcs7`
    iam_role = `curl http://169.254.169.254/latest/meta-data/iam/security-credentials/`
    vault_token = Vault.auth.aws_ec2(iam_role, signature, nil)
    vault_client = Vault::Client.new(address: ENV["VAULT_ADDR"], token: vault_token.auth.client_token)
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
  if e
    log "Received exception #{e} from Vault - attempt #{attempt}"
  end
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

### KV Secrets Engine

Vault's [KV secrets engine](https://developer.hashicorp.com/vault/docs/secrets/kv) has two versions: [v2](https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2) (versioned, default in Vault 0.10+) and [v1](https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v1) (unversioned). Use `Vault.kv(mount)` for v2 and `Vault.logical` for v1.

```ruby
# Check which version your mount uses
mounts = Vault.sys.mounts
mounts[:secret].options[:version] #=> "2" or "1"
```

#### KV v2 (versioned secrets)

```ruby
# Write and read
Vault.kv("secret").write("db/creds", username: "admin", password: "secret123")
secret = Vault.kv("secret").read("db/creds")
secret.data[:data] #=> { :username => "admin", :password => "secret123" }

# Read specific version
secret = Vault.kv("secret").read("db/creds", 2)

# List paths
Vault.kv("secret").list("db") #=> ["creds"]

# Soft delete (can be undeleted)
Vault.kv("secret").delete("db/creds")
Vault.kv("secret").delete_versions("db/creds", [1, 2])

# Undelete
Vault.kv("secret").undelete_versions("db/creds", [1])

# Permanently destroy
Vault.kv("secret").destroy_versions("db/creds", [1])
Vault.kv("secret").destroy("db/creds") # destroys all versions and metadata

# Metadata operations
Vault.kv("secret").write_metadata("db/creds", max_versions: 5)
metadata = Vault.kv("secret").read_metadata("db/creds")
```

#### KV v1 (unversioned secrets)

```ruby
Vault.logical.write("secret/db/creds", username: "admin", password: "secret123")
secret = Vault.logical.read("secret/db/creds")
secret.data #=> { :username => "admin", :password => "secret123" }

Vault.logical.list("secret/db") #=> ["creds"]
Vault.logical.delete("secret/db/creds") #=> true
```

#### Seal Status
```ruby
Vault.sys.seal_status
#=> #<Vault::SealStatus sealed=false, t=1, n=1, progress=0>
```

### Tokens

See the [Token Auth API docs](https://developer.hashicorp.com/vault/api-docs/auth/token) for details.

```ruby
# Create, lookup, renew, and revoke
token = Vault.auth_token.create(policies: ["app-read"], ttl: "1h", renewable: true)
info = Vault.auth_token.lookup_self
Vault.auth_token.renew_self(3600)
Vault.auth_token.revoke("hvs.CAESI...")
```

### Response wrapping

```ruby
# Request new access token as wrapped response where the TTL of the temporary
# token is "5s".
wrapped = Vault.auth_token.create(wrap_ttl: "5s")

# Unwrap the wrapped response to get the final token using the initial temporary
# token from the first request.
unwrapped = Vault.logical.unwrap(wrapped.wrap_info.token)

# Extract the final token from the response.
token = unwrapped.data.auth.client_token
```

A helper function is also provided when unwrapping a token directly:

```ruby
# Request new access token as wrapped response where the TTL of the temporary
# token is "5s".
wrapped = Vault.auth_token.create(wrap_ttl: "5s")

# Unwrap wrapped response for final token using the initial temporary token.
token = Vault.logical.unwrap_token(wrapped)
```

### API Coverage

Available Ruby clients:

- `Vault.kv(mount)` - [KV v2 secrets engine](https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2)
- `Vault.logical` - [KV v1](https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v1) and generic logical operations
- `Vault.sys` - [System backend](https://developer.hashicorp.com/vault/api-docs/system) (mounts, policies, seal status, etc.)
- `Vault.auth` - [Authentication methods](https://developer.hashicorp.com/vault/api-docs/auth) (AWS, AppRole, GitHub, etc.)
- `Vault.auth_token` - [Token auth](https://developer.hashicorp.com/vault/api-docs/auth/token)
- `Vault.approle` - [AppRole auth configuration](https://developer.hashicorp.com/vault/api-docs/auth/approle)
- `Vault.transform` - [Transform secrets engine](https://developer.hashicorp.com/vault/api-docs/secret/transform)
- `Vault.help` - Interactive help

For full API documentation, see [rubydoc.info/gems/vault](https://www.rubydoc.info/gems/vault) or check `spec/integration` for examples


Development
-----------
1. Clone the project on GitHub
2. Create a feature branch
3. Submit a Pull Request

Important Notes:

- **All new features must include test coverage.** At a bare minimum, Unit tests are required. It is preferred if you include integration tests as well.
- **The tests must be idempotent.** The HTTP calls made during a test should be able to be run over and over.
- **Tests are order independent.** The default RSpec configuration randomizes the test order, so this should not be a problem.
- **Integration tests require Vault**  Vault must be available in the path for the integration tests to pass.
   - **In order to be considered an integration test:** The test MUST use the `vault_test_client` or `vault_redirect_test_client` as the client. This spawns a process, or uses an already existing process from another test, to run against.
