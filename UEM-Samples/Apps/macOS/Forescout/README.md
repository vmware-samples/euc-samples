# Forescout SecureConnector

## Overview

- **Authors**: Matt Zaske
- **Email**: mzaske@vmware.com
- **Date Created**: 6/9/2022
- **Supported Platforms**: Workspace ONE UEM v2203
- **Tested on macOS Versions**: macOS Big Sur

## Purpose

Deploying Forescout SecureConnector for macOS with Workspace ONE UEM

1) Parse the pkg with the [Workspace ONE Admin Assistant](https://awagent.com/AdminAssistant/VMwareAirWatchAdminAssistant.dmg)
2) Modify the generated plist file as instructed.
3) Upload the pkg, plist, and icon to Workspace ONE UEM as an Internal App (Resources > Apps > Native > Internal)
4) In the __Scripts__ tab, add the scripts described.
5) Configure any remaining deployment settings and Assign the app as appropriate.

  > **NOTE:** Further info from Forescout can be seen here: https://docs.forescout.com/bundle/os-x-2-3-1-h/page/os-x-2-3-1-h.Managing-Endpoints-Using-SecureConnector.html#pID0E0SG0HA

## Package Deployment Details

After obtaining the correct package from Forescout directly, you will parse the pkg using the Admin Assistant. After that follow the below steps:
1) Edit the plist file that is created to ensure the 'Name' and 'Version' keys are in line with what you are expecting.
  * The Name key is how the app will appear in the UEM console as well as on the user's Hub Catalog.
2) Upload the pkg and plist files to UEM using the Add Application workflow (Resources > Apps > Native > Internal)
3) Add the icon under Images tab
4) Add the following scripts under the Scripts tab
  * Post Install Script - install the app using script built into pkg
  ```BASH
  #!/bin/bash

  #run update.sh from package
  sudo ./private/var/tmp/Update/Update.sh -t daemon -v 1
  rm -r /private/var/tmp/Update

  exit 0
  ```
  * Post Uninstall Script - ensure app is removed
  ```BASH
  #!/bin/bash
  rm -rf /Applications/ForeScout\ SecureConnector.app
  exit 0
  ```
  * Install Check Script - ensure Forescout is installed and proper version activated. Update the target version to what you are deploying in first line
  ```BASH
  #!/bin/bash

  # version of Forescout being deployed
  target_version=19.0.19006

  # Check if Forescout is installed First
  if [ -d "/Applications/ForeScout SecureConnector.app" ]; then

    #convert version number to individual
    function version { echo "$@" | /usr/bin/awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

    # grab current version of Forescout
    current_version=$(/usr/bin/defaults read /Applications/ForeScout\ SecureConnector.app/Contents/Info.plist CFBundleShortVersionString)
    echo current version: $current_version

    # Compare with the version we want to install
    if [ $(version $current_version) -lt $(version $target_version) ]; then
      # version installed is less than target - install
      echo Install Forescout
      exit 0
    else
      # version installed is same or greater than target - mark installed
      echo Forescout is installed
      exit 1
    fi
  else
    # Forescout is not installed - need to install
    echo Install Forescout
    exit 0
  fi
  ```

## Required Changes/Updates

None

## Change Log

- 2022-06-09: Created Initial File
