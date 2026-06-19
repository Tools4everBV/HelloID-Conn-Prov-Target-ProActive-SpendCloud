# Change Log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com), and this project adheres to [Semantic Versioning](https://semver.org).

## [2.0.4] - 11-06-2026

### Fixed
- Corrected user deletion query in `delete.ps1` to use `$actionContext.References.Account` directly, ensuring the intended user record is removed.
- Improved delete audit logging message clarity by reporting the deleted account username.

## [2.0.3] - 29-10-2025

### What's Changed
- Fixes and improvements after implementation by [@Rick-Jongbloed](https://github.com/Rick-Jongbloed) in [#4](https://github.com/Tools4everBV/HelloID-Conn-Prov-Target-ProActive-SpendCloud/pull/4)

## [2.0.2] - 11-09-2025

### What's Changed
- First v2 scripts by [@rscholtelubberink](https://github.com/rscholtelubberink) in [#2](https://github.com/Tools4everBV/HelloID-Conn-Prov-Target-ProActive-SpendCloud/pull/2)
- Updated readme by [@Rick-Jongbloed](https://github.com/Rick-Jongbloed) in [#3](https://github.com/Tools4everBV/HelloID-Conn-Prov-Target-ProActive-SpendCloud/pull/3)

### New Contributors
- [@rscholtelubberink](https://github.com/rscholtelubberink) made their first contribution in [#2](https://github.com/Tools4everBV/HelloID-Conn-Prov-Target-ProActive-SpendCloud/pull/2)
- [@Rick-Jongbloed](https://github.com/Rick-Jongbloed) made their first contribution in [#3](https://github.com/Tools4everBV/HelloID-Conn-Prov-Target-ProActive-SpendCloud/pull/3)

## [2.0.1] - 30-10-2024

### Changed
- Fixed comments

## [2.0.0] - 05-04-2024

### Changed
- Upgrade Powershell V2
