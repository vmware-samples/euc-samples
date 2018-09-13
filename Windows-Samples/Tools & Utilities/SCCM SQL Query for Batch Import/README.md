# SCCM SQL Query for AirWatch Batch Import

## Overview
- **Author**: Brooks Peppin & Josue Negron
- **Email**: jnegron@vmware.com
- **Date Created**: 12/1/2017
- **Updated:** 9/13/2018
- **Tested on**: SCCM 1706/1710 with SQL Server 2012

## Introducing VMware Workspace ONE AirLift
The main purpose and goal of VMware {code} is to share code samples and collaborate with our development community. We actively watch and listen to customer feedback and sometimes take some of the open-source projects and convert them into fully supported versions. We have recently released Workspace ONE AirLift, a server-side connector that simplifies and speeds the customers journey to modern management. Workspace ONE AirLift bridges administrative frameworks between Microsoft System Center Configuration Manager (SCCM) and Workspace ONE UEM. 
Workspace ONE AirLift provides the following features: 
1. Maps SCCM Device Collections to Workspace ONE UEM (AirWatch) Smart Groups via Tags
2. Automatically creates the Workspace ONE Enrollment app to Onboard SCCM Managed Devices
3. Migrate SCCM applications to Workspace ONE UEM and provides helpful validation warnings before Migration
4. Co-Management Dashboard to Track Progress and Activity Logging

- **Admin Guide:** https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/9.7/ws1_airlift.pdf
- **Installer:** https://resources.workspaceone.com/view/q3gx2btk3n4tltcc7nl4/en
- **Hands-on Lab (Modules 5 & 6):** http://labs.hol.vmware.com/hol/catalogs/lab/4680

## SYNOPSIS
In order to silently onboard Windows 10 devices into AirWatch and have them automatically assigned to the primary user, you will have to first preregister devices via a batch import. You can use the attached SQL queries to generate the CSV file needed to perform a batch import in AirWatch. 

Detailed instructions can be found at [http://www.brookspeppin.com](http://www.brookspeppin.com/blog/how-to-silently-enroll-windows-10-systems-into-airwatch-using-sccm)

[![Batch Import from SCCM to Workspace ONE](https://img.youtube.com/vi/93j-WL6LZBk/0.jpg)](https://www.youtube.com/watch?v=93j-WL6LZBk)

## Modifications Required
Update the following attributes before executing the script: 

- **YourGroupID** - Group ID of your OG
- **YourDeviceGroupID** - Enrollment OG for the Device
- **YourCollectionID** - Device Collection ID for the collection you want to export
- You might also want to remove anything after the WHERE statement to pull a larger group of devices, or to pull in device serial numbers which are virtual machines (VMs). 
- For fresh installs of System Center ConfigMgr, the **givenName** and **sn** AD attributes are not automatically synced, thus the SQL script will fail to pull these values in until you sync these attributes over. Production environments should already have these attributes syncing. 

        
There are two version **Simple** and **Advanced**, all that is required is simple however some will want to add additional attributes ahead of time so they are imported with the device records. 

## Resources
- [Brooks Peppin Blog with How to Steps](http://www.brookspeppin.com/blog/how-to-silently-enroll-windows-10-systems-into-airwatch-using-sccm)

##Change Log
-2/5/2018 - Updated Email Address AD Attribute from "vru.User_Principal_Name0" to "vru.Mail0"
-9/13/2018 - Added AirLift reference to README



