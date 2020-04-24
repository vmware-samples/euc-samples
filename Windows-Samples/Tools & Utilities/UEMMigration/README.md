# Device Migration Script

## Overview
- **Authors**: Mike Nelson
- **Email**: miken@vmware.com
- **Date Created**: 8/15/2019
- **Supported Platforms**: Workspace ONE 1907
- **Tested on**: Windows 10 Pro/Enterprise 1803+

## Purpose
The Migration script will help move a device between Workspace ONE UEM environments. 

**Note:** This does require the device to unenroll from the source environment and to re-enroll into the new environment.

## Description 
This script can be used to migrated existing devices to new environments. It does require an Enterprise Wipe in the Source environment so that enrollment can occur into the new environment.

The script needs to be run with administrator permissions. If it is started without admin permissions, then it will launch an Admistrative powershell session.

## Setup
The script requires the input of several variables before it can run. In the Source environment, API information is needed so that the script can find device information and issue an Enterprise Wipe. For the Destination Environment, the staging enrollment command line parameters need to be filled in so that command line enrollment can complete.

#### Source Environment Variables
* Fill in the API Username for the Source Environment on line 17 ```$SourceApiUsername = ""```
* Fill in the API Password for the Source Environment on line 18 ```$SourceApiPassword = ""```
* Fill in the API Key for the Source Environment on line 19 ```$SourceApiKey = ""```
* Fill in the URL for the Source Environment on line 20 ```$SourceURL = ""```


#### Destination Environment Variables

* Fill in the URL for the Destination Environment ```$DestinationURL = ""```
* Fill in the Organization Group Name for the Destination Environment ```$DestinationOGName = ""```
* Fill in the Username for the Staging User ```$StagingUsername = ""```
* Fill in the Password for the Stating User ```$StagingPassword = ""```

#### Stage the Hub App
The Hub app needs to be in the same directory as the script. It can be downloaded from https://getws1.com. 

#### Addtional Notes
The script will check for a network connection prior to beginning the enrollment process. If it detects that there is not an active connection it will pause so that the Admin/User/Technician can reconnect to the internet so that enrollment can complete.

## Running the script 

### With a UI
1. Ensure that the Script and the Hub app are located in the same directory.
1. From a Powershell prompt run ```.\UEMMigration.ps1```

### Silently
1. Ensure that the script and the Hub app are located in the same directory.
1. From a Powershell prompt run ```.\UEMMigration.ps1 -silent```


## Additional Resources
* [API Setup Documentation](https://cn135.awmdm.com/api/help/InitialSetup.html)
* [Command Line Enrollment - How to guide](https://techzone.vmware.com/onboarding-windows-10-using-command-line-enrollment-vmware-workspace-one-operational-tutorial)
