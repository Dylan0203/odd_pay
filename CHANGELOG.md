# Changelog

All notable changes to this project are documented in this file.

Entries below start at 0.2.0; earlier releases predate this file and are not backfilled.

## [0.2.0] - 2026-07-26

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
