# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

## [v2.0.4] - 2026-06-11

### Fixed
- Corrected user deletion query in `delete.ps1` to use `$actionContext.References.Account` directly, ensuring the intended user record is removed.
- Improved delete audit logging message clarity by reporting the deleted account username.
