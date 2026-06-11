# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Fixed
- Corrected user deletion query in `delete.ps1` to use `$actionContext.References.Account` directly, ensuring the intended user record is removed.
- Improved delete audit logging message clarity by reporting the deleted account username.# Changelog

Branch: `Updated-Readme` vs `main`

## Added

- New structured README following HelloID PowerShell connector V2 template.
- Feature matrix (Supported Features) covering: Account Lifecycle, Permissions, Resources, Entitlement Import (Accounts & Permissions unsupported), Governance Reconciliation (unsupported).
- Provisioning Lifecycle table with separate rows for `resources.ps1` (preferred) and `sa-export.ps1` (alternate).
- Split Data Flow section: Preferred (Resource script, one-run lag) and Alternate (SA task, immediate export).
- Configuration section generated from `configuration.json` (`database`, `destinationfile`, `destinationfileRoles`).
- Exported CSV Files section with exact Dutch column headers, differing delimiters, and processing notes.
- Important Information banner and SpendCloud logo.
- Rationale for SQLite intermediate layer.
- Guidance for choosing between export mechanisms (batching vs immediate).

## Changed

- Title updated to “HelloID Target Connector - ProActive SpendCloud”.
- Script descriptions clarified (correlate behavior, role rebuild logic).
- Correlation defaults (`ExternalId` / `externalId`) explicitly documented.
- Wording standardized; legacy phrasing removed.
- Consolidated logging and configuration guidance.

## Removed

- Legacy sections (Getting started, Connector settings, Mapping, Supported PowerShell versions) replaced by standardized template sections.
- Previous minimal introduction and sparse export explanation.
- Redundant or outdated role assignment text.

## Technical / Script Impact

- Adjustments across scripts: `Resources/resources.ps1`, `sa-export.ps1`, `create.ps1`, `update.ps1`, `delete.ps1`, `configuration.json`, `fieldMapping.json` (CSV naming consistency, removal of unused variables, roles export logic refinement).

## Commits (not in main)

1. cb5691a Rename CSV files, remove unused variables
2. 52d1b38 Updated Readme (added roles, extra info)
3. 5a8cf4d Updated connector after implementation
4. 071302d updated readme

----
If you need to publish this changelog for a release, consider tagging a version and adding a date header (e.g., `## [Unreleased] - 2025-10-29`).
