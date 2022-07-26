# macOS Updater Utility (mUU)

## Overview

- **Authors**: Matt Zaske
- **Email**: mzaske@vmware.com
- **Date Created**: 7/22/2022
- **Supported Platforms**: Workspace ONE UEM v2204
- **Tested on macOS Versions**: macOS Big Sur and Monterey (Intel and Apple Silicon)

## Purpose

The macOS Updater Utility (mUU) keeps your Mac device fleet up to date by prompting and, if needed, forcing users to update to your specified version of macOS. mUU utilizes [Apple's MDM Commands](https://developer.apple.com/documentation/devicemanagement/scheduleosupdatecommand/command/updatesitem) to download and install the needed updates via the Workspace ONE UEM API. The tool will allow you to specify max number of deferrals, deferral grace period and more! Read more to find out how to deploy this solution using Workspace ONE UEM!

1. [Prerequisites for mUU](#prerequisites-for-mUU)
    1. [API Credentials](#api-credentials)
2. [Deploying macOS Updater Utility](#deploying-macOS-updater-utility)
    1. [Script](#script)
    2. [Profile](#profile)

## Prerequisites for mUU
- macOS Version 11.0 (Big Sur) or higher recommended. This tool has not been tested on anything previous to Big Sur.
- UEM v21.11 or higher with Freestyle Orchestrator is recommended in order to utilize "Scripts" engine. See more information here: https://kb.vmware.com/s/article/81163

#### API Credentials
In order to make the MDM commands to download and install macOS updates, mUU utilizes the Workspace ONE UEM API. The following steps need to be taken to ensure the proper credentials can be supplied when deploying the script:
1. Navigate to Groups & Settings > Configurations within your UEM Console
2. Search for and select "OAuth Client Management"
3. Select "Add" and fill in the details similar to below. Feel free to modify as you see fit:
    1. <img width="1165" alt="image" src="https://user-images.githubusercontent.com/63124926/181052726-89d89b96-9c20-4817-9946-d8ef55639e14.png">
4. After selecting "Save" you will need to note/save the Client ID and Secret. These will be needed in a later step when deploying the script. 

## Deploying macOS Updater Utility
#### Script
1. Navigate to Resources > Scripts within your UEM Console
2. Select "Add" followed by "macOS"
3. Fill out the "General" tab as you see fit leaving "App Catalog Customization" disabled
4. On the "Details" tab you will do the following:
    1. Leave the "Language" as Bash and "Execution Context" as System
    2. The timeout will need to be set to 30 seconds longer than "promptTimer" which is explained in the [Profile](#profile) section below
    3. Upload or copy/paste the contents of the `macOSupdater.sh` file: 
5. After selecting "Next" you will configure the "Variables" section. It is very important that the variables names match exactly as below (screenshot as well for reference):
6. insert table
7. insert screenshot 

#### Profile


## Notes


## Resources

## Required Changes/Updates

- Updates to come:
  - Icon file improvements
  - Battery and Disk Space verification
  - Improved error handling

## Change Log

- 2022-07-22: Created Initial File
