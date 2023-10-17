# macOS Updater Utility (mUU)
<p align="center">
    <img width="500" alt="image" src="https://github.com/mzaske3/euc-samples/assets/63124926/1466c174-21d5-4fc0-8a28-2f1fd52ddcde">
</p>
## Overview


- **Authors**: Matt Zaske, Leon Letto, and others
- **Email**: mzaske@vmware.com
- **Date Created**: 7/22/2022
- **Supported Platforms**:
    - VMware Workspace ONE UEM (22.10+) with Freestyle Workflow Engine (Scripts engine required)
    - VMware Workspace ONE Intelligent Hub for macOS (22.12+)
- **Tested on macOS Versions**: macOS 11+ (Intel and Apple Silicon CPU)

## Purpose

The macOS Updater Utility (mUU) keeps your Mac device fleet up to date by prompting users to update to your specified version of macOS. If necessary, mUU will force users to update their OS. mUU utilizes [Apple's MDM Commands](https://developer.apple.com/documentation/devicemanagement/scheduleosupdatecommand/command/updatesitem) to download and install updates via the Workspace ONE UEM API. mUU will allow you to specify max number of deferrals, deferral grace period, and more! Read more to find out how to deploy this solution using Workspace ONE UEM. 
<p align="center">
    <img width="532" alt="image" src="https://user-images.githubusercontent.com/63124926/181076575-23266933-bff4-46fd-adf9-ab332054f994.png">
</p>

1. [Prerequisites for mUU](#prerequisites-for-mUU)
    1. ~~[API Credentials](#api-credentials)~~
2. [Deploying macOS Updater Utility](#deploying-macOS-updater-utility)
    1. [Script](#script)
    2. [Profile](#profile)

## Prerequisites for mUU
- macOS Version 11.0 (Big Sur) or higher recommended. This tool has not been tested on anything previous to Big Sur.
- Intelligent Hub for macOS v22.12 or higher
- UEM v22.10 or higher with Freestyle Orchestrator is recommended in order to utilize "Scripts" engine. See more information here: https://kb.vmware.com/s/article/81163

#### ~~API Credentials~~
No longer required with revision 13. The tool now utilizes hubCLI to make the request to Workspace ONE. 

## Deploying macOS Updater Utility
#### Script
1. Navigate to Resources > Scripts within your UEM Console
2. Select "Add" followed by "macOS"
3. Fill out the "General" tab as you see fit leaving "App Catalog Customization" disabled
4. On the "Details" tab you will do the following:
    1. Leave the "Language" as Bash and "Execution Context" as System
    2. The timeout will need to be set to 30 seconds longer than "promptTimer" which is explained in the [Profile](#profile) section below
    3. Upload or copy/paste the contents of the `macOSupdater.sh` [file](https://github.com/mzaske3/euc-samples/blob/master/UEM-Samples/Utilities%20and%20Tools/macOS/macOS%20Updater%20Utility/macOSupdater.sh)
5. After selecting "Next" you will see the "Variables" screen. There is nothing you need to configre here (new in revision 13).
6. Then select "Save" and you will be taken back to the Scripts List View. Here you will select the bubble the left of your Script and select "Assign"
7. Selct "New Assignement" and fill in the "Definition" tab as needed. Ensure to scope the assignment to only devices intended to upgrade using proper smart group.
8. After selecting "Next" you will configure the "Deployment" tab:
    1. Here you will select "Run Periodically" and select the time interval.
    2. This time interval will coorespond to the user's deferral grace period (i.e. how long a user will have once they defer an update prompt until they are prompted again). I would suggest using 4 hours as the default value.
    3. Be careful with using multiple triggers as it could cause the script to launch multiple times at once which would cause multiple pop-ups to the user at one time. 

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
| maxDays | integer | 10 | The number of days the user has to defer the update before it is forced. This key will take precendence over maxDeferrals. |
| deadlineTime | string | 19:30 | Optional (default: 06:00) - The time in which the update will be enforced on the given deadline date (controlled by maxDays). Must me in format hh:mm (the mUU will not enforce at this exact time, but on the next time the script executes). |

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
- 2023-05-04: Revision 11.1:
    - Minor fix to RSR install verification
    - Logic improvements:
        - Latest Mode will now also enforce the latest RSR if available
        - When specifying a RSR patch in desiredOS (i.e. 13.3.1 (a)) the tool will first ensure the device is on 13.3.1 before it will try to install RSR patch
- 2023-05-04: Revision 11.2: 
    - Added fallback logic for obtaining productKey for RSR installation
- 2023-05-18: Revision 11.3:
    - Fix for latest mode download when using on a machine for first time
    - Fix for RSR Version sensor for machines on 13.3.1
- 2023-08-01: Revision 12:
    - Deadline Mode:
        - Enable this feature to have the mUU utilize a deadline to enforce updates instead of maximum number of deferrals.
        - Utilize the maxDays and deadlineTime key-value pairs in the custom settings profile to enable this feature. See more details [here](#profile).
    - macOS Sonoma Support:
        - You will now be able to enforce macOS Sonoma update (once available).
    - Major Version Update - logic enhancement:
        - mUU ensures the installer for a major update now matches the exact version you are wanting to enforce.
- 2023-08-03: Revision 12.1:
    - Syntax fix for major updates
- 2023-08-04: Revision 12.2:
    - Logic enhancement for latest mode
- 2023-09-28: Revision 13:
    - MDM Commands via hubCLI:
        - Removes the need to use the API and supply credentials to the tool.
    - Minor fixes:
        -  Deadline mode time formatting
        -  macOS Sonoma logic
- 2023-10-17: Revision 13.1:
    - Fix for displaying deadline date on user prompt screen
