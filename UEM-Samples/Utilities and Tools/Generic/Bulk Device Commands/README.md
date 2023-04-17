# Bulk Command Script

## Overview
- **Author**: Mike Nelson
- **Email**: miken@vmware.com
- **Date Created**: 02/05/2019
- **Tested on Workspace One UEM 1811**: Completed

## SYNOPSIS
This Powershell script allows you to issue commands to groups of devices in bulk that are available via API but not currently in the console. Commands such as Device Lock or Enterprise Reset can be issued against a targeted group of devices to speed up Admin tasks. 

**Requirements**

- Must have access to an Workspace One UEM Admin Account that can authenticate to the APIs with Basic (Certificates currently not supported)
- Must have access to the Workspace One UEM Admin API Key

## DESCRIPTION
When run, the script will retrieve a list of devices from the provided Smart Group and execute the provided command against those devices.

## Modifications Required

1. You will need to supply your AirWatch Admin credentials, including the AirWatch API Key.

## EXAMPLE
```
.\Bulk-DeviceCommand.ps1 `
    -awServer "https://YourTenant.com" `
    -awTenantAPIKey "YourAPIKey" `
    -awAPIUsername "YourUserName" `
    -awAPIPassword "YourPassword" `
    -smartGroup "Beta Testers" `
    -command "Lock" `
    -Verbose
```
## Parameters

**awServer**

Server URL for the AirWatch API Server

**awAPIUsername**

The username of an AirWatch account being used in the target AirWatch server.  This user must have a role that allows API access.

**awAPIPassword**

The password of the AirWatch account specified by the awUsername parameter.

**awTenantAPIKey**

This is the REST API key that is generated in the AirWatch Console.  You locate this key at All Settings -> Advanced -> API -> REST, and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access, which is available at Customer type Organization Groups.

**smartGroup**

The Smart Group name that the command will be issued against, e.g. "Beta Users"

**command**

Command to be sent to devices.

Commands tested include "Lock", "EnterpriseReset".
