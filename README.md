# HelloID-Conn-Prov-Target-ProActive

| :information_source: Information |
|:---------------------------|
| This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements. |

<br />

<p align="center">
  <img src="https://proactive-software.com/wp-content/uploads/2020/04/pa-logo.svg">
</p>

## Table of contents

- [HelloID-Conn-Prov-Target-ProActive](#helloid-conn-prov-target-proactive)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Connector settings](#connector-settings)
    - [Mapping](#mapping)
    - [On-Premises requirement](#on-premises-requirement)
    - [Exported CSV files](#exported-csv-files)
    - [Correlation](#correlation)
  - [Getting help](#getting-help)
  - [HelloID Docs](#helloid-docs)

## Introduction

HelloID target connector for ProActive (SpendCloud).  
This connector uses a local SQLite database as an intermediate step to create export files for SpendCloud. All changes to persons and their contracts are written to this database, after which CSV files are generated and processed by SpendCloud.  

These CSV files are designed to be processed by the standard CSV import functionality within SpendCloud.  

| Action        | Action(s) Performed                        | Comment |
|---------------|--------------------------------------------|---------|
| create.ps1    | Create or correlate SpendCloud DB row      | Creates or correlates a row in the database and updates the roles table. If correlation is configured, updates are processed. |
| update.ps1    | Update SpendCloud DB row                   | Updates DB row, removes and re-sets roles. |
| delete.ps1    | Archive SpendCloud DB row                  | Removes the DB row. |

<!-- GETTING STARTED -->
## Getting started

### Prerequisites

- This connector requires an On-Premise HelloID Agent.
- Windows PowerShell 5.1 must be installed on the On-Premise server running the HelloID Agent.
- SQLite must be installed on the On-Premise server.  
  Installation can be done by running the `install.ps1` script (as Administrator).

### Connector settings

The following custom connector settings are available and required:

| Setting              | Description |
|-----------------------|-------------|
| SQLITE DATABASE FILE  | The SQLite database file on the On-Premise server. Please provide the complete path (e.g. `D:\HelloID\SQLite\Database\ProActive.db`). |
| VERBOSE LOGGING       | Enable or disable verbose logging. |

### Mapping

The mandatory and recommended field mapping is listed below. Some fields are required by SpendCloud and must be set when creating an account. During an update, required/immutable fields are set to existing values from the existing user.  

The mapping file is included in this repository.  

### On-Premises requirement

This connector **always requires an On-Premise HelloID Agent**.  
The reason is that the connector generates CSV files (`Users.csv` and `Roles.csv`) which are written to a local or network location. These files are then picked up by SpendCloud or a process managed by the SpendCloud functional administrator or supplier.  

The export of `Users.csv` and `Roles.csv` is executed via a scheduled HelloID Service Automation task.  
No additional HelloID licenses are required for this functionality.  

Running this connector purely in the cloud is not possible, because file system access is mandatory for the export process.

### Exported CSV files

From the intermediate SQLite database, two CSV files are generated:  

1. **Users.csv** – contains user information:  
   - FirstName  
   - MiddleName  
   - LastName  
   - Gender  
   - Email  
   - Username  

2. **Roles.csv** – contains all contracts that are currently in scope (technically: `inCondition`; functionally: usually all active contracts):  
   - Organizational Unit  
   - Username  
   - Function Profile Code  

The files are placed on a designated network location.  

- **Users.csv** is used to create and update users in SpendCloud.  
- **Roles.csv** is used to assign and manage roles within SpendCloud.  

Processing of these files is handled either by a scheduled process configured by the SpendCloud functional administrator or by the SpendCloud supplier.  

For the processing of these files, an import job must be configured within ProActive.  
Depending on the environment, additional setup by the ProActive supplier or functional administrator may be required.  

### Correlation

It is mandatory to enable correlation in the correlation tab.  

- Default "Person Correlation field" = `ExternalId`  
- Default "Account Correlation field" = `externalId`

## Getting help

> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/en/provisioning/target-systems/powershell-v2-target-systems.html) pages._  

> _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)._  

## HelloID Docs

The official HelloID documentation can be found at: <https://docs.helloid.com/>
