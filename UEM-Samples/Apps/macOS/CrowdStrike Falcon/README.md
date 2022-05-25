# CrowdStrike Falcon Agent

## Overview

- **Authors**: Matt Zaske
- **Email**: mzaske@vmware.com
- **Date Created**: 5/25/2022
- **Supported Platforms**: Workspace ONE UEM v2203
- **Tested on macOS Versions**: macOS Big Sur

## Purpose

Deploying CrowdStrike Falcon Agent for macOS with Workspace ONE UEM

1) Deploy configuration profile with all the needed payloads
2) Download the profile Falcon Agent pkg
3) Parse the pkg with the [Workspace ONE Admin Assistant](https://awagent.com/AdminAssistant/VMwareAirWatchAdminAssistant.dmg)
4) Modify the generated plist file as instructed.
5) Upload the pkg, plist, and icon to Workspace ONE UEM as an Internal App (Resources > Apps > Native > Internal)
6) In the __Scripts__ tab, add the scripts described.
7) Configure any remaining deployment settings and Assign the app as appropriate.

## Configuration Profile Creation

CrowdStrike provides the necessary profile as a mobileconfig file directly [here](a.	https://supportportal.crowdstrike.com/s/article/Tech-Alert-Preparing-for-macOS-Falcon-Sensor-6-11). This is meant to help decipher the plist and create a profile in UEM. All information below can be found in the mobileconfig file directly.

1) Click **Add > Profile > macOS > Device** and complete the General information
2) Select the **System Extension Policy** payload an click configure
3) Complete the payload (Allow User Overrides can be selected or not, up to the organization), and include the following information in the *Allowed System Extensions* list:
  * Team ID: X9E956P446
  * Bundle ID: com.crowdstrike.falcon.Agent
4) Include the following information in the *Allowed System Extension Types* list:
  * Team ID: X9E956P446
  * Select the boxes for Endpoint Security and Network
5) Select the **Privacy Preferences** payload an click configure
6) Select Add App and add the following details:
  * Identifier: com.crowdstrike.falcon.Agent
  * Identifier Type: Bundle ID
  * Code Requirement: identifier "com.crowdstrike.falcon.Agent" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = X9E956P446
  * System Policy All Files: Allow
7) After selecting save, select Add App again and add the following details:
  * Identifier: com.crowdstrike.falcon.App
  * Identifier Type: Bundle ID
  * Code Requirement: identifier "com.crowdstrike.falcon.App" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = X9E956P446
  * System Policy All Files: Allow
8) Select the **Content Filter** payload an click configure
9) Complete the payload using the following information (if information is not provided below then you can leave as default values):
  * Filter Type: Plug-in
  * Filter Name: Falcon
  * Identifier: com.crowdstrike.falcon.App
  * Organization: CrowdStrike Inc.
  * Filer WebKit Traffic: Disabled (Not Checked)
  * Filter Socket Traffic: Enabled (Checked)
  * Custom Data (5 additional key-value pairs to be added):
    * FilterDataProviderBundleIdentifier - com.crowdstrike.falcon.Agent
    * FilterDataProviderDesignatedRequirement - identifier "com.crowdstrike.falcon.Agent" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] and certificate leaf[field.1.2.840.113635.100.6.1.13] and certificate leaf[subject.OU] = "X9E956P446"
    * FilterPacketProviderBundleIdentifier - com.crowdstrike.falcon.Agent
    * FilterPacketProviderDesignatedRequirement - identifier "com.crowdstrike.falcon.Agent" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] and certificate leaf[field.1.2.840.113635.100.6.1.13] and certificate leaf[subject.OU] = "X9E956P446"
    * FilterGrade - inspector
  10) Save and publish the profile

  > **NOTE:** When adding Custom Data for the Content Filter payload the value shown first goes in the "Key" column and the second value after the dash (-) goes in the "Value" column

## Package Deployment Details

After obtaining the correct package from CrowdStrike directly, you will parse the pkg using the Admin Assistant. After that follow the below steps:
1) Edit the plist file that is created to ensure the 'Name' and 'Version' keys are in line with what you are expecting.
  * The Name key is how the app will appear in the UEM console as well as on the user's Hub Catalog.
2) Upload the pkg and plist files to UEM using the Add Application workflow (Resources > Apps > Native > Internal)
3) Add the icon under Images tab
4) Add the following scripts under the Scripts tab
  * Post Install Script - needed to activate the license, replace INSERT_LICENSE_HERE with the actual license string
  ```BASH
  #!/bin/sh
  /Applications/Falcon.app/Contents/Resources/falconctl license INSERT_LICENSE_HERE
  exit 0
  ```
  * Post Uninstall Script - ensure app is removed if functionality is enabled. No maintenance token, if token is needed – add it after uninstall in line
  ```BASH
  #!/bin/sh
  sudo /Applications/Falcon.app/Contents/Resources/falconctl uninstall
  exit 0
  ```
  * Install Check Script - ensure CrowdStrike is installed and proper version activated. Update the target version to what you are deploying in first line
  ```BASH
  #!/bin/sh
  target_version=6.26.13904.0

  #convert version number to individual
  function version { echo "$@" | /usr/bin/awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

  # Grab current version of installed crowdstrike
  current_version=$(/usr/bin/sudo /Applications/Falcon.app/Contents/Resources/falconctl stats | /usr/bin/grep version | /usr/bin/awk '{print $2}')
  echo CrowdStrike version $current_version

  # Compare with the version we want to install
  if [ $(version $current_version) -lt $(version $target_version) ]; then
      echo install CrowdStrike
      exit 0
  else
      echo CrowdStrike is installed
      exit 1
  fi
  ```

## Required Changes/Updates

None

## Change Log

- 2022-05-25: Created Initial File
