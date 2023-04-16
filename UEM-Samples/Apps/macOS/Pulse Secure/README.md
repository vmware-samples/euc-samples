# Pulse Secure

## Overview

- **Authors**: Matt Zaske
- **Email**: mzaske@vmware.com
- **Date Created**: 6/9/2022
- **Supported Platforms**: Workspace ONE UEM v2203
- **Tested on macOS Versions**: macOS Big Sur

## Purpose

Deploying Pulse Secure for macOS with Workspace ONE UEM

1) Parse the DMG with the [Workspace ONE Admin Assistant](https://awagent.com/AdminAssistant/VMwareAirWatchAdminAssistant.dmg)
2) Modify the generated plist file as instructed.
3) Upload the DMG, plist, and icon to Workspace ONE UEM as an Internal App (Resources > Apps > Native > Internal)
4) In the __Scripts__ tab, add the scripts described.
5) Configure any remaining deployment settings and Assign the app as appropriate.

  > **NOTE:** Further info from Pulse Secure can be seen here: https://docs.pulsesecure.net/WebHelp/PDC/9.0R1/Content/PDC_AdminGuide_9.0R1/Installing_the_Pulse_Client_1.htm

## Package Deployment Details

After obtaining the correct installer from Pulse Secure directly, you will parse the DMG using the Admin Assistant. After that follow the below steps:
1) Edit the plist file that is created to ensure the 'Name' and 'Version' keys are in line with what you are expecting.
  * The Name key is how the app will appear in the UEM console as well as on the user's Hub Catalog.
2) Upload the pkg and plist files to UEM using the Add Application workflow (Resources > Apps > Native > Internal)
3) Add the icon under Images tab
4) Add the following scripts under the Scripts tab
  * Pre Install Script - create pulse.config file in the install directory. Edit the script to insclude your specific file information by pasting the contents of your preconfig file to line 9:
  ```BASH
  #!/bin/sh

  #create pulse.config file in install directory
  PATH="/Library/Application Support/AirWatch/Data/Munki/Managed Installs/Cache"
  /bin/mkdir -p "$PATH"
  /usr/bin/touch "$PATH/pulse.config"
  /bin/chmod 644 "$PATH/pulse.config"
  /bin/cat > "$PATH/pulse.config" <<- EOM
  PASTE PRECONFIG FILE CONTENTS HERE (in between lines 8 and 10)
  EOM

  exit 0
  ```
  * Post Install Script - import preconfig file and then clean up
  ```BASH
  #!/bin/sh
  #import pulse.config
  /Applications/Pulse\ Secure.app/Contents/Plugins/JamUI/jamCommand -importfile /Library/Application\ Support/AirWatch/Data/Munki/Managed\ Installs/Cache/pulse.config
  #clean up pulse.config file
  rm -rf /Library/Application\ Support/AirWatch/Data/Munki/Managed\ Installs/Cache/customer.json
  exit 0
  ```
  * Uninstall Script - ensure app is removed
  ```BASH
  #!/bin/sh
  #call built in uninstall script
  sh /Library/Application\ Support/Pulse\ Secure/Pulse/Uninstall.app/Contents/Resources/uninstall.sh
  exit 0
  ```
  * Install Check Script - ensure Pulse Secure is installed and proper version activated. Update the target version to what you are deploying in first line
  ```BASH
  #!/bin/bash

  # version of Pulse Secure being deployed
  target_version=9.1.13

  # Check if Pulse Secure is installed First
  if [ -d "/Applications/Pulse Secure.app" ]; then

    #convert version number to individual
    function version { echo "$@" | /usr/bin/awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

    # Grab current Pulse version installed
    current_version=$(/usr/bin/defaults read /Applications/Pulse\ Secure.app/Contents/Info.plist CFBundleShortVersionString)
    echo Pulse Secure version: $current_version

    # Compare with version we are expecting
    if [ $(version $current_version) -lt $(version $target_version) ]; then
      echo Pulse Secure not installed
      exit 0
    else
      echo Pulse Secure is installed
      exit 1
    fi

  else
    # pulse is not installed - need to install
    echo Install Pulse Secure
    exit 0
  fi
  ```

## Required Changes/Updates

None

## Change Log

- 2022-06-09: Created Initial File
