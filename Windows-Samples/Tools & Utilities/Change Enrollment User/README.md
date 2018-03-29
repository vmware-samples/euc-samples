# Change Enrollment User Tool

## Overview
- **Author**: Mike Nelson
- **Email**: miken@vmware.com
- **Date Created**: 03/28/2018
- **Tested on AirWatch 9.3.0.0**: Completed

## SYNOPSIS
This Powershell script allows you to make a server side change to a device record in AirWatch. This script changes the record in AirWatch from the Staging User to the desired End User. This script can be used to make server side management of devices easier if devices have been enrolled to one user.

**Requirements**

- Must use AirWatch 9.3+
- Must have access to an AirWatch Admin Account that can authenticate to the APIs with Basic (Certificates currently not supported)
- Must be targeting devices enrolled to a Staging user for Single Staging. Multi-User staging is Not Supported.

## DESCRIPTION
When run, this script will prompt you to select a csv file that contains Device Serial number mapping to desired End User.

## Modifications Required

1. The template CSV needs to be filled out with the appropriate device and user mapping.
1. You will need to supply your AirWatch Admin credentials, including the AirWatch API Key, when prompted.

## EXAMPLE

    .\Change-EnrollmentUser.ps1 `
        -awServer "https://mondecorp.ssdevrd.com" `
        -awTenantAPIKey "iVvHQnSXpX5elicaZPaIlQ8hCe5C/kw21K3glhZ+g/g=" `
        -awAPIUsername "tkent" `
        -awAPIPassword "SecurePassword" `
        -Verbose


## Parameters

**awServer**

Server URL for the AirWatch API Server

**awAPIUsername**

The username of an AirWatch account being used in the target AirWatch server.  This user must have a role that allows API access.

**awAPIPassword**

The password of the AirWatch account specified by the awUsername parameter.

**awTenantAPIKey**

This is the REST API key that is generated in the AirWatch Console.  You locate this key at All Settings -> Advanced -> API -> REST, and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access, which is available at Customer type Organization Groups.

**serialNum**

The serial number of the device to work with.

**uName**

The targeted enrollment user.
