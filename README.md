# HelloID-Conn-Prov-Target-ProActive

| :information_source: Information |
|:---------------------------|
| This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.       |

<br />

<p align="center">
  <img src="https://proactive-software.com/wp-content/uploads/2020/04/pa-logo.svg">
</p>

## Table of contents

- [Introduction](#Introduction)
- [Getting started](#Getting-started)
  + [Prerequisites](#Prerequisites)
  + [Connector settings](#Connector-settings)
  + [Mapping](#Mapping)
  + [Supported PowerShell versions](#Supported-PowerShell-versions)
  + [Correlation](#Correlation)
- [Getting help](#Getting-help)
- [HelloID Docs](#HelloID-Docs)

## Introduction

HelloID target connector for ProActive. This target connector uses a SQLite database as the intermediate step for the actual export to CSV. The new persons are placed in this database and possibly updated if required. When a person no longer gets access to ProActive, the persons are also deleted from this database.

To finally send the persons to ProActive, a Service Automation task is running from a schedule and creates an export in CSV with the required data to create, manage or delete the accounts in ProActive.
A secondary 'roles' table will be filed with all contracts incondition for setting permissions in Spendcloud. Roles should match 1-1 in both systems for this to work.

The fields that are exported are "voornamen, tussenvoegsel, achternaam, gebruikersnaam, email". 
> A CSV import job has to be created in ProActive for this connector to work.

| Action                          | Action(s) Performed   | Comment   | 
| ------------------------------- | --------------------- | --------- |
| create.ps1                      | Create or correlate Spendcloud DB row  | Create or correlates an row in the database & updates roles table. If correlateion is configured, the update will be processed |
| update.ps1                      | Update Spendcloud DB row  | Update DB row, removes and re-sets roles. |
| delete.ps1                      | Archive Spendcloud DB row  | Removes the DB row. |
 
 <!-- GETTING STARTED -->
## Getting started


### Prerequisites

- This connector requires an On-Premise HelloID Agent
- Using the HelloID On-Premises agent, Windows PowerShell 5.1 must be installed.
- Installation of SQLite must be done on the On-Premise server which runs the HellloID Agent
- Installation of SQLite can be done by running the install.ps1 script (must be ran as admin).

### Connector settings

The following custom connector settings are available and required:

| Setting     | Description |
| ------------ | ----------- |
| SQLITE DATABASE FILE | The SQLite database file on the On-Premise server. Please fill the complete path (e.g. "D:\HelloID\SQLite\Database\ProActive.db") |
| VERBOSE LOGGING | Enable or Disable the Verbose logging of the script |

### Mapping
The mandatory and recommended field mapping is listed below. Some fields are required by Spendcloud and are set on creating an account. When an update is triggered, the required/immutable fields are set to the existing values from the existing user.

Mapping file added in repository

### Supported PowerShell versions

The connector is created for Windows PowerShell 5.1. This means that the connector can not be executed in the cloud and requires an On-Premises installation of the HelloID Agent.

> Older versions of Windows PowerShell are not supported.

### Correlation
It is mandatory to enable the correlation in the correlation tab. The default value for "person correlation field" is " ExternalId". The default value for "Account Correlation field" is "externalId".

## Getting help

> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/en/provisioning/target-systems/powershell-v2-target-systems.html) pages_

> _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)_

## HelloID Docs

The official HelloID documentation can be found at: https://docs.helloid.com/
