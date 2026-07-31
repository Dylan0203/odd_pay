# Changelog

All notable changes to this project are documented in this file.

Entries below start at 1.1.0; earlier releases predate this file and are not backfilled.

## [1.1.1] - 2026-08-01

### Changed

- `spgateway_payment_and_invoice_client` now resolves from
  `Dylan0203/spgateway_payment_and_invoice` at tag `1.0.10`, replacing
  `oracle-design` at `1.0.8`.

  `1.0.8` still calls `URI.encode` and `URI.decode`, both removed in Ruby 3.0.
  `1.0.9` replaced the four request-building `URI.encode` sites; `1.0.10` the
  three response-parsing `URI.decode` sites.

  **No behaviour change here.** odd_pay talks to NewebPay exclusively through
  `Spgateway::ClientV2`, which builds requests with `URI.encode_www_form` and
  parses responses with `JSON.parse` — it contains no `URI.decode` and is
  byte-identical across `1.0.8`, `1.0.9` and `1.0.10`. This pin exists so
  odd_pay's own development environment resolves the same gem source its
  consumers do. The trap it removes is latent: the first change here reaching for
  `Spgateway::Client`, `InvoiceClient` or `LinePayClient` would otherwise get a
  gem that raises on Ruby 3.x, and the specs stub the client so they could not
  catch it.

  The fork is temporary. Move back to `oracle-design` once
  <https://github.com/oracle-design/spgateway_payment_and_invoice/pull/7> merges.

### Note on versioning

`1.1.0` was briefly followed by a `0.2.0` tag (commit `52bd053`) that moved the
version *backwards*. That was a mistake: an automated task in a consuming
project's upgrade plan treated its plan document's "release 0.2.0" wording as
authoritative over this repository's own history, which had already reached
`1.1.0` by normal semver continuation from `1.0.1`. The `0.2.0` tag is
code-identical to `1.1.0` — the only differences were `version.rb` and this file.
This release continues the `1.x` line.

## [1.1.0] - 2026-07-26

### Changed

- `rails` dependency narrowed from `>= 6.1, < 8.0` to `>= 6.1, < 7.2`. The wider range was
  never verified past Rails 7.1, so the constraint now matches what has actually been tested.
  Consumers on Rails 6.1–7.1 are unaffected; anyone relying on the untested 7.2+ range should
  pin explicitly.
- `IdHashable#SALT` now reads `Rails.application.secret_key_base` instead of
  `Rails.application.secrets.secret_key_base` — `Rails.application.secrets` was removed in
  Rails 7.1.

### Added

- Ruby 3.1 and Ruby 3.4 are now supported and verified (previously only Ruby 2.7 was tested).
  Full spec suite green on both, alongside the existing Rails 6.1.7 / 7.1.6 pairings.
