# SCCM to Airwatch Device Registration

## Overview
- **Author**: Chris Halstead
- **Email**: chalstead@vmware.com
- **Date Created**: 2/20/2018
- **Updated:** 5/1/2018
- **Tested on**: SCCM 2012 R2 and AirWatch 9.3
- **Version**: 2.0

## SYNOPSIS
In order to silently onboard Windows 10 devices into AirWatch and have them automatically assigned to the primary user, you will have to first preregister devices via a batch import. You can use the attached script to perform a batch import of these device records into AirWatch.  
This script connects to SCCM via WMI, gathers the devices in a collection, checks to see if they are registered in Airwatch, and if they are not it registers the device in Airwatch to the primary user of the device.  

## Parameters 

**SCCMServer**

Name of the SCCM Server you want to connect to


**SCCMCollectionName**

Name of a Collection in the SCCM site which you want to query devices from

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

SCCM 2012 R2 or later and Airwatch 9.x

Must be run with an account that has access to SCCM WMI Provider

Airwatch account with at least API privileges needed


##Change Log

2/20/2018 - Published

5/1/2018 - Version 2.0 - Changed script so it will connect via remote WMI to the SCCM Server.  It no longer needs to be run locally on the SCCM Server





