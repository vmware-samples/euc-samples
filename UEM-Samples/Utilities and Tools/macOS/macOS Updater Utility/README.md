# macOS Updater Utility (mUU)

## Overview

- **Authors**: Matt Zaske, Leon Letto, and others
- **Email**: mzaske@vmware.com
- **Date Created**: 7/22/2022
- **Supported Platforms**: Workspace ONE UEM with Freestyle Workflow Engine (Scripts engine required) 
- **Tested on macOS Versions**: macOS 11+ (Intel and Apple Silicon CPU)

## Purpose

The macOS Updater Utility (mUU) keeps your Mac device fleet up to date by prompting users to update to your specified version of macOS. If necessary, mUU will force users to update their OS. mUU utilizes [Apple's MDM Commands](https://developer.apple.com/documentation/devicemanagement/scheduleosupdatecommand/command/updatesitem) to download and install updates via the Workspace ONE UEM API. mUU will allow you to specify max number of deferrals, deferral grace period, and more! Read more to find out how to deploy this solution using Workspace ONE UEM. 
<p align="center">
    <img width="532" alt="image" src="https://user-images.githubusercontent.com/63124926/181076575-23266933-bff4-46fd-adf9-ab332054f994.png">
</p>

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
4. After selecting "Save" you will need to note/save the Client ID and Secret. This is the only time you will be able to access the Client Secret, so ensure to keep it in a safe place. These will be needed in a later step when deploying the script. 

## Deploying macOS Updater Utility
#### Script
1. Navigate to Resources > Scripts within your UEM Console
2. Select "Add" followed by "macOS"
3. Fill out the "General" tab as you see fit leaving "App Catalog Customization" disabled
4. On the "Details" tab you will do the following:
    1. Leave the "Language" as Bash and "Execution Context" as System
    2. The timeout will need to be set to 30 seconds longer than "promptTimer" which is explained in the [Profile](#profile) section below
    3. Upload or copy/paste the contents of the `macOSupdater.sh` [file](https://github.com/mzaske3/euc-samples/blob/master/UEM-Samples/Utilities%20and%20Tools/macOS/macOS%20Updater%20Utility/macOSupdater.sh)
5. After selecting "Next" you will configure the "Variables" section. It is very important that the variables names match exactly as below (see table and screenshot below).
6. Then select "Save" and you will be taken back to the Scripts List View. Here you will select the bubble the left of your Script and select "Assign"
7. Selct "New Assignement" and fill in the "Definition" tab as needed. Ensure to scope the assignment to only devices intended to upgrade using proper smart group.
8. After selecting "Next" you will configure the "Deployment" tab:
    1. Here you will select "Run Periodically" and select the time interval.
    2. This time interval will coorespond to the user's deferral grace period (i.e. how long a user will have once they defer an update prompt until they are prompted again). 

| Variable Name | Value | Example | 
|---|---|---|
| apiURL | The API URL for your Workspace ONE UEM tenant. | https://as1380.awmdm.com | 
| clientID | The Client ID that was generated in the Prerequisites section. | abcd1234abcd1234 | 
| clientSec | The Client Secret that was generated in the Prerequisites section. | ABCDEFG1234567ABCDEFG1234567 | 
| tokenURL | The URL for the Workspace ONE Token Service in your region, [seen here](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/UEM_ConsoleBasics/GUID-BF20C949-5065-4DCF-889D-1E0151016B5A.html ). | https://na.uemauth.vmwservices.com/connect/token | 

<img width="899" alt="image" src="https://user-images.githubusercontent.com/63124926/181089063-3266f78b-9604-4f43-bd3e-96ad08f61489.png">

#### Profile
The behavior the end user experiences is controlled by a configuration profile that is deployed through Workspace ONE UEM:
1. Click **Add > Profile > macOS > Device** and complete the General information
    1. Ideally you would assign this profile to the same smart group that you assigned the Script to.
2. Select the "Custom Settings" payload and select "Add" or "Configure"
3. Paste in the XML content from the `macOSupdaterSettings.xml` [file](https://github.com/mzaske3/euc-samples/blob/master/UEM-Samples/Utilities%20and%20Tools/macOS/macOS%20Updater%20Utility/macOSupdaterSettings.xml)
    1. Make any modifications as you see fit to the customizable options shown below.
4. Save and Publish the profile once completed.

Here is a breakdown of the keys and their meaning:
| Key | Type | Default | Function |
|---|---|---| ---|
| desiredOSversion | string | 12.5 | The version of macOS want your devices to update to. Set this value to 'latest' in order to enforce the most recent minor build for a given device. RSR patch can be enforced as well using '(a)' after the desired OS version. Examples: 12.4, latest, 13.3.1 (a) |
| promptTimer | string | 300 | The amount of time in seconds that the prompt to upgrade or defer is displayed to the user before it times out. If no action is taken and the prompt times out, it does count as a deferral to the user. |
| maxDeferrals | integer | 10 | The number of times the user can defer the update before it is forced. |
| buttonLabel | string | Upgrade | The text displayed on the button to the user that triggers the OS Update. |
| messageIcon | string | /System/Applications/App Store.app/Contents/Resources/AppIcon.icns | The location of the icon to be used in the prompt to the user. Do not escape spaces in the path. |
| messageTitle | string | Approved macOS Update Ready | The title of the prompt dialog box that is displayed to the user. |
| messageBody | string | This will upgrade your computer the latest version of macOS. It will quit out of all open applications. Please make sure to save your documents and data before proceeding. This installation will restart your computer and may take several minutes to complete. If you have questions and/or concerns, please contact your IT Support team. | The message body of the prompt dialog box that is displayed to the user. |
| proxy | string | This will be used by the tool to help the device connect to the API and Token URLs if required. If the device can connect freely to the API and Token endpoints then this is not needed to be included. |

## Notes
- Action is only taken on the device (i.e. user prompted) if both the Script and Profile are deployed to the device and the following criteria are met:
    - User is logged into the Mac
    - Current OS version is less than the desired OS version
- The tool will log to `/Library/Logs/macOSupdater.log`
    - This log can also be retrieved via the Workspace ONE UEM console using the "More Actions > Retrieve Device Log" functionality.
    - Once the log bundle is retrieved you will find the log in the `/data/ProductsNew` directory
- New logging and comparison functions added in Revision 10
    - Logger: https://github.com/leonletto/bashLogger 
    - Compare Numbers: https://github.com/leonletto/bash_compare_numbers

## Required Changes/Updates

- Updates to come:
  - Icon file improvements
  - Battery and Disk Space verification
  - Deadline functionality

## Change Log

- 2022-07-22: Created Initial File
- 2022-08-19: Improved minor update download verification and installation methods
- 2022-09-01: Enhanced logging and error handling for API failures
- 2022-09-14: Various minor fixes and added functionality to customize button text displayed to user
- 2023-01-18: Revision 10:
    - New logging
        - Check out here: https://github.com/leonletto/bashLogger 
    - Fix for macOS 13 major update download
    - Added proxy support for API connection
    - Minor product key enhancement (used for macOS 11 and below)
- 2023-01-26: Update to revision 10, fix proxy error when proxy not supplied
- 2023-05-03: Revision 11:
    - Latest Mode:
        - Enable this feature to have the mUU always enforce the latest minor build on your devices once it is released by Apple.
    - Rapid Security Response (RSR) Support:
        - You will now be able to enforce RSR patch installs on your devices.
        - See the Sensors directory for additional reporting in this area as well. 
