# Arctic Wolf Agent

## Overview

- **Authors**: Matt Zaske
- **Email**: mzaske@vmware.com
- **Date Created**: 6/6/2022
- **Supported Platforms**: Workspace ONE UEM v2203
- **Tested on macOS Versions**: macOS Big Sur

## Purpose

Deploying Arctic Wolf Agent for macOS with Workspace ONE UEM

1) Parse the pkg with the [Workspace ONE Admin Assistant](https://awagent.com/AdminAssistant/VMwareAirWatchAdminAssistant.dmg)
2) Modify the generated plist file as instructed.
3) Upload the pkg, plist, and icon to Workspace ONE UEM as an Internal App (Resources > Apps > Native > Internal)
4) In the __Scripts__ tab, add the scripts described.
5) Configure any remaining deployment settings and Assign the app as appropriate.

  > **NOTE:** Further info from Arctic Wolf can be seen here: https://docs.arcticwolf.com/agent/installing_mac.html

## Package Deployment Details

After obtaining the correct package from Arctic Wolf directly, you will parse the pkg using the Admin Assistant. After that follow the below steps:
1) Edit the plist file that is created to ensure the 'Name' and 'Version' keys are in line with what you are expecting.
  * The Name key is how the app will appear in the UEM console as well as on the user's Hub Catalog.
  * I would suggest editing the version to only use decimals, no underscores or hyphens.
2) Upload the pkg and plist files to UEM using the Add Application workflow (Resources > Apps > Native > Internal)
3) Add the icon under Images tab
4) Add the following scripts under the Scripts tab
  * Pre Install Script - create customer.json file in the install directory. Edit the script to insclude your specific UUID and hostname.
  ```BASH
  #!/bin/sh

  #create customer.json file in install directory
  PATH="/Library/Application Support/AirWatch/Data/Munki/Managed Installs/Cache"
  /bin/mkdir -p "$PATH"
  /usr/bin/touch "$PATH/customer.json"
  /bin/chmod 644 "$PATH/customer.json"
  /bin/cat > "$PATH/customer.json" <<- EOM
  {"customerUuid":"INSERT_UUID","registerDns":"INSERT_HOSTNAME"}
  EOM
  exit 0
  ```
  * Post Install Script - clean up customer.json file
  ```BASH
  #!/bin/sh
  #clean up customer.json file
  rm -rf /Library/Application\ Support/AirWatch/Data/Munki/Managed\ Installs/Cache/customer.json
  exit 0
  ```
  * Post Uninstall Script - ensure app is removed
  ```BASH
  #!/bin/sh
  sudo ./Library/ArcticWolfNetworks/Agent/uninstall.sh
  exit 0
  ```
  * Install Check Script - ensure Arctic Wolf is installed and proper version activated. Update the target version to what you are deploying in first line
  ```BASH
  #!/bin/bash

  # version of Arctic Wolf being deployed - convert hyphen and underscores to decimal
  target_version="2020-11_02"
  target_version=$(echo "$target_version" | /usr/bin/tr '-' '.' | /usr/bin/tr '_' '.')

  # Check if Arctic Wolf is installed first
  if [ -f "/Library/ArcticWolfNetworks/Agent/etc/scoutversion.json" ]; then

    #convert version number to individual
    function version { echo "$@" | /usr/bin/awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

    # Grab current Arctic Wolf version installed - convert hyphen and underscores to decimal
    current_version=$(/bin/cat /Library/ArcticWolfNetworks/Agent/etc/scoutversion.json | /usr/bin/cut -d ":" -f 2 | /usr/bin/sed -e '1d;3d' | /usr/bin/tr -d '"",' | /usr/bin/tr '-' '.' | /usr/bin/tr '_' '.')
    echo Arctic Wolf current version: $current_version

    # Compare with version we are expecting
    if [ $(version $current_version) -lt $(version $target_version) ]; then
      # version installed is not current
      echo Arctic Wolf not installed
      exit 0
    else
      # version installed is current or newer
      echo Arctic Wolf is installed
      exit 1
    fi

  else
    # arctic wolf is not installed - need to install
    echo Install Arctic Wolf
    exit 0
  fi
  ```

## Required Changes/Updates

None

## Change Log

- 2022-06-06: Created Initial File
