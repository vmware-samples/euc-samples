# EUC-samples is now hosted https://github.com/euc-oss/euc-samples.
# This repo is no longer maintained.

# Pagination Recursion Sample

## Overview

* Author: Justin Sheets
* Email: jsheets@vmware.com
* Date Created: 01/27/2022
* Tested On: Workspace ONE UEM 21.11

## Description
This sample shows how you can use recursion to query all records in paginated Workspace ONE UEM APIs

## Requirements
1. Powershell
2. Workspace ONE UEM API credentials
2. Workspace ONE UEM API Key

## Instructions

**Note: This current version of the script is meant as a starter template. It can easily be extended to take in parameters to increase flexibilty**

1. Modify/Update the App json file for the application.
    1. Templates are provided to assist in this process. Fill in the correct information for the application.
    1. The script will update *filename*, *LocationGroupId*, and *blob/transactionid*
    1. Default values are provided.
1. In the variables section fill in the following information
    1. $Username is the API Username
    1. $Password is the API Password
    1. $API Key - Found under the REST API settings in the console.
    1. $OrgGroupId - Numeric ID of the Organization Group where app is to be managed.
        * Can be found under Organization Group details, number is in the url.
    1. $ServerURL - API url of server, found under site urls.
    1. $AppFilePath - Path to app file for upload
    1. $AppMetaDataFilePath - Path to json file for upload.

**Note: Chunk Size can be increased or decreased. Do not exceed 100MB.**

## Detection Criteria
The sample provides one example for AppExists, if this needs to be changed then the following templates should replace file exists.

#### File Exists
Below is an example of FileExists, most of the fields can be modified to match what is set for the app being uploaded.

```json
{
    "CriteriaType": "FileExists",
    "FileCriteria": {
        "Path": "Path to File ",
        "VersionCondition": "GreaterThan",
        "MajorVersion": 16,
        "MinorVersion": 0,
        "RevisionNumber": 0,
        "BuildNumber": 0,
        "ModifiedOn": "1999-02-03"
    },
    "LogicalCondition": "End"
}
```