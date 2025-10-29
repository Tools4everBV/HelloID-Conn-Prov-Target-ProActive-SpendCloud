# HelloID Target Connector - ProActive SpendCloud

> [!IMPORTANT]
> This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.

![ProActive SpendCloud Logo]([https://raw.githubusercontent.com/Tools4everBV/HelloID-Conn-Prov-Target-ProActive-SpendCloud/refs/heads/main/Icon.png](https://raw.githubusercontent.com/Tools4everBV/HelloID-Conn-Prov-Target-ProActive-SpendCloud/refs/heads/Updated-Readme/Logo.png)

## Table of Contents

- [HelloID Target Connector - ProActive SpendCloud](#helloid-target-connector---proactive-spendcloud)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Supported Features](#supported-features)
  - [Provisioning Lifecycle](#provisioning-lifecycle)
  - [Data Flow](#data-flow)
    - [Preferred Flow (Resource Script `resources.ps1`)](#preferred-flow-resource-script-resourcesps1)
    - [Alternate Flow (Service Automation Task `sa-export.ps1`)](#alternate-flow-service-automation-task-sa-exportps1)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [Field Mapping](#field-mapping)
  - [Correlation](#correlation)
  - [Exported CSV Files](#exported-csv-files)
    - [Users.csv](#userscsv)
    - [Roles.csv](#rolescsv)
    - [Processing Notes](#processing-notes)
  - [On-Premises Requirement](#on-premises-requirement)
  - [Getting Help](#getting-help)
  - [Official HelloID Documentation](#official-helloid-documentation)

## Introduction

This HelloID target connector provisions and updates users and contract-based role assignments for ProActive SpendCloud via an intermediate local SQLite database. Each provisioning action writes data to SQLite; scheduled Service Automation (SA) tasks export CSV files which are then imported by SpendCloud.

Why SQLite intermediate?

- Simplifies incremental provisioning (create/update/delete) before export.
- Enables correlation logic and re-computation of role assignments.
- Decouples HelloID run-time from SpendCloud import schedule.

## Supported Features

| Feature                                   | Supported | Actions                                       | Remarks           |
| ----------------------------------------- | --------- | ----------------------------------------------| ------------------|
| **Account Lifecycle**                     | ✅        | Create, Update, Enable, Disable, Delete       |                   |
| **Permissions**                           | ✅        | Managed via create, update and delete scripts | All contracts that are in scope of the account business rule|
| **Resources**                             | ✅        | Export DB data to users and roles csv files   |                   |
| **Entitlement Import: Accounts**          | ❌        | -                                             |                   |
| **Entitlement Import: Permissions**       | ❌        | -                                             |                   |
| **Governance Reconciliation Resolutions** | ❌        | -                                             |                   |

## Provisioning Lifecycle

| Script | Action(s) Performed | Notes |
|--------|---------------------|-------|
| `create.ps1` | Create or correlate user; inserts role rows for in-scope contracts. | If correlation hits, starts the update process |
| `update.ps1` | Update existing user row; deletes existing roles and re-inserts current in-scope contracts. | Uses property comparison to limit updates. |
| `delete.ps1` | Remove user and related role rows. | Requires account reference (`gebruikersnaam`). |
| `resources.ps1` | Preferred export (Resource script) writing `Users.csv` and `Roles.csv`. | Runs one provisioning cycle behind (next run reflects previous lifecycle changes). |
| `sa-export.ps1` | Alternate export (Service Automation scheduled task). | Exports in the same run; choose this when you require immediate csv-file availability. |

## Data Flow

Two export patterns are supported. The Resource script flow is preferred; the SA task flow is an alternate when you need immediate CSV availability.

### Preferred Flow (Resource Script `resources.ps1`)

1. Scheduled Resource script (`resources.ps1`) runs and exports `Users.csv` / `Roles.csv` based on the database state from the previous provisioning cycle (inherent one-run lag).
2. HelloID lifecycle scripts (`create.ps1`, `update.ps1`, `delete.ps1`) execute during the day (or trigger window) and write changes to SQLite (`persons`, `roles`).
3. Changes accumulate; no immediate export occurs (batching multiple lifecycle events).
4. On the next scheduled run of `resources.ps1`, the updated accumulated state is exported, and SpendCloud subsequently ingests the new CSV files.

### Alternate Flow (Service Automation Task `sa-export.ps1`)

1. HelloID provisioning (create / update / delete) runs and writes changes to SQLite (`persons`, `roles`).
2. The SA export task (`sa-export.ps1`) is triggered on set scheduling window and exports `Users.csv` and `Roles.csv`.
3. SpendCloud ingests the exported CSV files and applies changes.

When to choose which:

- Use the Resource flow for routine daily operations and keep track on all the changes done in provisioning.
- Use the SA task flow if operationally required to see account/role changes reflected in files within the same execution window.

## Prerequisites

- On-Premise HelloID Agent (mandatory).
- Windows PowerShell 5.1.
- Local or network-accessible SQLite installation & write permissions.
- Execution rights to run `install.ps1` (Administrator) to deploy SQLite and required PowerShell modules.

## Installation

1. Deploy files to the HelloID On-Premise Agent scripts folder.
2. Run `install.ps1` as Administrator to install/update SQLite & modules.
3. Create/Configure the target connector in HelloID using this repository content.
4. Schedule Service Automation task for export (`sa-export.ps1` or `resources.ps1`).
5. Configure SpendCloud CSV import job referencing exported `Users.csv` and `Roles.csv` paths.

## Configuration

Connector configuration fields (from `configuration.json`):

| Key | Label (UI) | Description | Required |
|-----|------------|-------------|----------|
| `database` | SQLite Database file | Full path to the SQLite database file (e.g. `D:\HelloID\SQLite\Database\ProActive.db`). | Yes |
| `destinationfile` | Persons destination | Full path (including filename) where `Users.csv` will be written. | Yes |
| `destinationfileRoles` | Roles destination file | Full path (including filename) where `Roles.csv` will be written. | No |

Additional (implicit) runtime options:

- Verbose logging can be enabled in HelloID connector execution settings to get detailed debug output.

## Field Mapping

Mandatory and recommended field mappings are defined in `fieldMapping.json`. Required SpendCloud attributes must be present on create. Immutable or mandatory values are preserved during update if absent in source.

## Correlation

Correlation must be enabled to prevent duplicate user records.

- Default Person Correlation field: `ExternalId`
- Default Account Correlation field: `externalId`

On `create.ps1`, if correlation value matches an existing row, the script sets an account reference and logs a correlate action instead of a duplicate create.

## Exported CSV Files

Exact column lay-out and delimiters as produced by the export scripts (`resources.ps1` preferred, `sa-export.ps1` alternate):

### Users.csv

Delimiter: `;` (semicolon)

Columns (Dutch field names from SQLite):

- `voornaam` (First name)
- `tussenvoegsel` (Prefix / Middle part)
- `achternaam` (Last name)
- `geslacht` (Gender)
- `email` (Email address)
- `gebruikersnaam` (Login / Username)

### Roles.csv

Delimiter: `,` (comma)

Columns (exported with aliased Dutch headings):

- `Organisatorische Eenheid` (Source column `ou`)
- `Gebruikersnaam` (Source column `gebruikersnaam`)
- `Functieprofiel Code` (Source column `functiecode`)

### Processing Notes

- `Users.csv` is used by SpendCloud to create or update user accounts.
- `Roles.csv` manages function profile role assignments per user.
- Ensure the SpendCloud import job expects the exact Dutch headers shown above; do not rename unless the SpendCloud mapping is adjusted accordingly.

## On-Premises Requirement

This target cannot run in cloud mode because file system access is required to write CSV exports before SpendCloud ingestion. The On-Premise Agent is therefore mandatory. No additional HelloID licenses required for the export mechanism.

## Getting Help

For more information on configuring HelloID PowerShell connectors, consult the official documentation.

Community & Support:

- Docs: <https://docs.helloid.com/en/provisioning/target-systems/powershell-v2-target-systems.html>
- Forum: <https://forum.helloid.com>

## Official HelloID Documentation

Full documentation: <https://docs.helloid.com/>
