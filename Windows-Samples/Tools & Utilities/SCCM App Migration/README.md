# SCCM App Migration Tool

## Overview
- **Author**: Varun Murthy 
- **Email**: vmurthy@vmware.com
- **Date Created**: 08/07/2017
- **Tested on SCCM 1702**: Completed

## SYNOPSIS
    This Powershell script allows you to automatically migrate SCCM applications over to AirWatch for management from the AirWatch console.
        
## DESCRIPTION
    When run, this script will prompt you to select an application for migration. It then parses through the deployment details of the 
    application and pushes the application package to AirWatch. The script then maps all the deployment commands and settings over to the 
    AirWatch application record. MSIs are ported over as-is. Script deployments are ported over as ZIP folders with the correct execution 
    commands to unpack and apply them.
	
## Modifications Required
	This script must be run as an admin

## Known Issues
	One some screens the form that shows the SCCM Apps does not render correctly. You can still select an app and hit Enter.
	
## EXAMPLE

    .\Migrate-SCCMApps-AirWatch.ps1 `
        -SCCMSiteCode "PAL:" `
        -AWServer "https://mondecorp.ssdevrd.com" `
        -userName "tkent" `
        -password "SecurePassword" `
        -tenantAPIKey "iVvHQnSXpX5elicaZPaIlQ8hCe5C/kw21K3glhZ+g/g=" `
        -groupID "652" `
        -Verbose
        
## Parameters

**SCCMSiteCode**

The Site Code of the SCCM Server that the script can set the location to.

**AWServer**

Server URL for the AirWatch API Server
  
**userName**

An AirWatch account in the tenant is being queried.  This user must have the API role at a minimum.

**password**

The password that is used by the user specified in the username parameter

**tenantAPIKey**

This is the REST API key that is generated in the AirWatch Console.  You locate this key at All Settings -> Advanced -> API -> REST, and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access

**groupID**

The groupID is the ID of the Organization Group where the apps will be migrated. The API key and admin credentials need to be authenticated
    at this Organization Group. 

The shorcut to getting this value is to navigate to **https://<YOUR HOST>/AirWatch/#/AirWatch/OrganizationGroup/Details**.
The ID you are redirected to appears in the URL (7 in the following example). **https://<YOUR HOST>/AirWatch/#/AirWatch/OrganizationGroup/Details/Index/7**
