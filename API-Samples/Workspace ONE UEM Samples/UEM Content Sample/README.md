# Content REST API Example
REST APIs for Content Management

## Overview
- **Author:** Scot Curry
- **Email:** scotc@vmware.com
- **Date Created:** 9/23/2019
- **Supported Platforms:** Workspace ONE UEM 1811+

## Purpose
This script shows how to use the Workspace ONE REST API calls to download content from Content repositories.  This can be used as an example of the information required to dowload content.

## Description
This project consists of two files **RunParams.json** and **PullContent.ps1**.  You *should* be able to just update the **RunParams.json** file.  The *PullContent.ps1* reads the values from the **RunParams.json** file at runtime.

## Parameters
**UEMConsole** - This will be the Workspace ONE UEM tenant (ex. https://cn1506.awmdm.com - There is no check to validate there is no / at the end, so don't add one.

**UEMUsername** - This will be an Admin User that at the very least has API access.

**UEMPassword** - The password associated with the UEMUsername parameter.

**UEMRESTAPIKey** - This will be an *Admin* API key that either exists or can be created at All Settings - System - Advanced - API - REST API.

**BaseFolder** - This is the folder where the conent will be delivered.  This actually downloads all of the content files from the Customer level OG and writes them to a local folder.  There is not check for the folder to exists, so please make sure it is created.

**Note** - Because this is a JSON file backslashes (\) are considered escape characters.  For a Windows folder you will need to add something like C:\\\Temp\\\Content.  For Mac devices, you can use /Temp/Content.
