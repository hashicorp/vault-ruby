# Vault Ruby Changelog

## v0.1.3.dev (Unreleased)

IMPROVEMENTS

- Add support for using a custom CA cert [GH-8]
- Allow clients to specify timeouts [GH-12, GH-14]

BUG FIXES

- Read local token (`~/.vault-token`) for token if present [GH-13]
- Disable bad SSL cipher suites and force TLSv1.2 [GH-16]

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
