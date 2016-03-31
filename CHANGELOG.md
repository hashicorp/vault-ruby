# Vault Ruby Changelog

## v0.4.0 (March 31, 2016)

NEW FEATURES

- Add LDAP authentication method [GH-61]
- Add GitHub authentication method [GH-37]
- Add `create_orphan` method [GH-65]
- Add `lookup` and `lookup_self` for tokens
- Accept `VAULT_SKIP_VERIFY` environment variable [GH-66]

BUG FIXES

- Prefer `VAULT_TOKEN` environment variable over disk to mirror Vault's own
  behavior [GH-98]
- Do not duplicate query parameters on HEAD/GET requests [GH-62]
- Yield exception in `with_retries` [GH-68]

## v0.3.0 (February 16, 2016)

NEW FEATURES

- Add API for `renew_self`
- Add API for `revoke_self`
- Add API for listing secrets where supported

BUG FIXES

- Relax bundler constraint
- Fix race conditions on Ruby 2.3
- Escape path params before posting to Vault

## v0.2.0 (December 2, 2015)

IMPROVEMENTS

- Add support for retries (clients must opt-in) [GH-47]

BUG FIXES

- Fix redirection on POST/PUT [GH-40]
- Use `$HOME` instead of `~` for shell expansion

## v0.1.5 (September 1, 2015)

IMPROVEMENTS

- Use headers instead of cookies for authenticating to Vault [GH-36]

BUG FIXES

- Do not set undefined OpenSSL options
- Add `ssl_pem_passphrase` as a configuration option [GH-35]

## v0.1.4 (August 15, 2015)

IMPROVEMENTS

- Add support for using a custom CA cert [GH-8]
- Allow clients to specify timeouts [GH-12, GH-14]
- Show which error caused the HTTPConnectionError [GH-30]
- Allow clients to specify which SSL cipher suites to use [GH-29]
- Allow clients to specify the SSL pem password [GH-22, GH-31]

BUG FIXES

- Read local token (`~/.vault-token`) for token if present [GH-13]
- Disable bad SSL cipher suites and force TLSv1.2 [GH-16]
- Update to test against Vault 0.2.0 [GH-20]
- Do not attempt a read on logical path write [GH-11, GH-32]

## v0.1.3 (May 14, 2015)

BUG FIXES

- Decode logical response body if present

## v0.1.2 (May 3, 2015)

BUG FIXES

- Require vault/version before accessing Vault::VERSION in the client
- Improve Travis CI test coverage
- README and typo fixes

## v0.1.1 (April 4, 2015)

- Initial release
