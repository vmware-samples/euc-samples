# SCCM to Airwatch Tag Creation

## Overview
- **Author**: Chris Halstead
- **Email**: chalstead@vmware.com
- **Date Created**: 2/20/2018
- **Updated:** 2/20/2018
- **Tested on**: SCCM 2012 R2 and AirWatch 9.2.3

## SYNOPSIS
This script connects to SCCM via WMI and retrieves Device collections and members. The script will create a Tag in the specified Airwatch environment for a specified colllection or all Device collections. Each memeber of the collection is queryied in Airwatch and if the devices exists, the tag will be applied to the device.  This allows correlation between SCCM and Airwatch for co-existance.  Devices can still be grouped with SCCM collections, but managed through Airwatch for tasks such as software distribution. 

## Parameters 

**SCCMCollectionName**

Name of a Collection in the SCCM site which you want to query devices from.  Input All to create a tag for each decice collection in SCCM and to tag each member of the collection in Airwatch.

**AirwatchServer**

Server URL for the AirWatch API Server
  
**AirwatchUser**

An AirWatch account in the tenant is being queried.  This user must have the API role at a minimum.

**AirwatchPW**

The password that is used by the user specified in the username parameter

**AirwatchAPIKey**

This is the REST API key that is generated in the AirWatch Console.  You locate this key at All Settings -> Advanced -> API -> REST, and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access

**OrganizationGroupName**

The name of the Organization Group where the devices will be registered. The API key and admin credentials need to be authenticated at this Organization Group. 

## Resources

Prerequisites:

*SCCM 2003 or later and Airwatch 9.x

*Must be run locally on the SCCM server with an Admin account

*Airwatch account with at least API privileges needed


##Change Log
-2/23/2018 - Published



