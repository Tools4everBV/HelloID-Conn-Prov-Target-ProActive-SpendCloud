# HelloID-Conn-Prov-Target-ProActive

<p align="center">
  <img src="https://proactive-software.com/wp-content/uploads/2020/04/pa-logo.svg">
</p>

## Table of contents

- [Introduction](#Introduction)
- [Getting started](#Getting-started)
  + [Connector settings](#Connector-settings)
  + [Prerequisites](#Prerequisites)
  + [Supported PowerShell versions](#Supported-PowerShell-versions)
- [Getting help](#Getting-help)
- [HelloID Docs](#HelloID-Docs)

## Introduction

HelloID target connector for ProActive. This target connector uses a SQLite database as the intermediate step for the actual export to CSV. The new persons are placed in this database and possibly updated if required. When a person no longer gets access to ProActive, the persons are also deleted from this database.

To finally send the perons to ProActive, a Service Automation task is running from a schedule and creates an export in CSV with the required data to create, manage or delete the accounts in ProActive.

## Getting started

### Connector settings

The following custom connector settings are available and required:

| Setting     | Description |
| ------------ | ----------- |
| SQLITE DATABASE FILE | The SQLite database file on the On-Premise server. Please fill the complete path (e.g. "D:\HelloID\SQLite\Database\ProActive.db") |
| VERBOSE LOGGING | Enable or Disable the Verbose logging of the script |

### Prerequisites

- This connector requires an On-Premise HelloID Agent
- Using the HelloID On-Premises agent, Windows PowerShell 5.1 must be installed.
- Installation of SQLite must be done on the On-Premise server which runnes the HellloID Agent
- Installation of SQLite can be done by running the install.ps1 script.

### Supported PowerShell versions

The connector is created for Windows PowerShell 5.1 and higher. This means that the connector can not be executed in the cloud and requires an On-Premises installation of the HelloID Agent.

> Older versions of Windows PowerShell are not supported.

## Getting help

> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/hc/en-us/articles/360012518799-How-to-add-a-target-system) pages_

> _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)_

## HelloID Docs

The official HelloID documentation can be found at: https://docs.helloid.com/
