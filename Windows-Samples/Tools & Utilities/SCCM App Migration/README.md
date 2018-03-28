# SCCM App Migration Tool

## Overview
- **Author**: Varun Murthy / Mike Nelson / Chris Halstead
- **Email**: vmurthy@vmware.com / miken@vmware.com / chalstead@vmware.com
- **Date Created**: 08/07/2017
- **Date Updated**: 03/15/2018
- **Tested on SCCM 1702**: Completed

## SYNOPSIS
This Powershell script allows you to create a report of the applications in SCCM with related meta-data and automatically migrate SCCM applications over to AirWatch for management from the AirWatch console.
        
## DESCRIPTION
When run, the script will prompt for which process that should be run. Select 1 to generate a report of the applications in SCCM or Select 2 to move previously reported applications to AirWatch with their meta-data. The script parses the information in SCCM and generates a report assoicating the application with the relevant AirWatch Meta-data. Once option 2 is run, the script will iterate through the csv report and upload the apps to AirWatch. Once the apps are uploaded they will need to be assigned to the appropriate Smart Groups.

**Note:** A CSV report must be generated first in order to move the applications to AirWatch.

## Recommended Workflow

1. Run option 1 to generate a csv report for the applications in SCCM, if there are a lot of apps it may take some time for the script to generate the report.
1. Review the report and delete any apps that do not need to be migrated.
1. Run option 2 of the script and select the csv report that was generated and edited in Steps 1 & 2.
 1. Optional - Break the applications into small batches of the csv and move them in batches as opposed to one big push. E.g. select 5 apps from the main report by saving a copy of the csv with only those targeted applications.
	
## Modifications Required
This script must be run as an admin

## Known Issues

* Depending on the SCCM environment setup, the script may not be able to upload the application from SCCM. This is typical a result of permissions issues in more secure environments. If that fails, the application may need to be manually downloaded.
	
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

The Site Code of the SCCM Server that the script can set the location to. Ensure you enter in the 3 character site code followed by a colon. 

**AWServer**

Server URL for the AirWatch API Server
  
**userName**

An AirWatch account in the tenant is being queried.  This user must have the API role at a minimum.

**password**

The password that is used by the user specified in the username parameter

**tenantAPIKey**

This is the REST API key that is generated in the AirWatch Console.  You locate this key at All Settings -> Advanced -> API -> REST, and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access

**groupID**

The groupID is the ID of the Organization Group where the apps will be migrated. The API key and admin credentials need to be authenticated at this Organization Group. 

The shorcut to getting this value is to navigate to **https://<YOUR HOST>/AirWatch/#/AirWatch/OrganizationGroup/Details**.
The ID you are redirected to appears in the URL (7 in the following example). **https://<YOUR HOST>/AirWatch/#/AirWatch/OrganizationGroup/Details/Index/7**

**Changelog**

3/14/18 - Mike Nelson - Update processing of .CSV
3/15/18 - Chris Halstead - Update logic of processing UninstallString




