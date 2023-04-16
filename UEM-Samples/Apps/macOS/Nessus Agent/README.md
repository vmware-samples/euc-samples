# Nessus Agent

## Overview

- **Authors**: Matt Zaske
- **Email**: mzaske@vmware.com
- **Date Created**: 6/9/2022
- **Supported Platforms**: Workspace ONE UEM v2203
- **Tested on macOS Versions**: macOS Big Sur

## Purpose

Deploying Nessus Agent for macOS with Workspace ONE UEM

1) Create a new pkg using the DMG that is supplied from Tenable
2) Parse the pkg with the [Workspace ONE Admin Assistant](https://awagent.com/AdminAssistant/VMwareAirWatchAdminAssistant.dmg)
3) Modify the generated plist file as instructed.
4) Upload the pkg, plist, and icon to Workspace ONE UEM as an Internal App (Resources > Apps > Native > Internal)
5) In the __Scripts__ tab, add the scripts described.
6) Configure any remaining deployment settings and Assign the app as appropriate.

  > **NOTE:** Further info from Tenable can be seen here: https://docs.tenable.com/nessus/Content/InstallNessusAgentMacOSX.htm

## Create pkg from DMG

After obtaining the DMG file for Nessus Agent, perform the following steps to build a pkg that you can deploy with Workspace ONE:
1) Mount the DMG file locally
2) Copy the 2 packages that are located on the DMG (1 of them is a hidden pkg)
3) Paste these 2 packages into a new file structure locally that you will use to build a new pkg (I use the path /private/var/tmp, it is important this path matches your post install script):
  - <img width="771" alt="image" src="https://user-images.githubusercontent.com/63124926/172905112-5e1da4b1-b25a-4409-a377-f13e33703ed0.png">
5) Build new pkg using terminal:
  ```BASH
	pkgbuild --install-location / --identifier "com.company.nessusagent" --version "1.0" --root ./payload/ --scripts ./scripts/ ./build/NessusAgent.pkg
  ```

## Package Deployment Details

After building new pkg using the instructions above, you will parse the pkg using the Admin Assistant. After that follow the below steps:
1) Edit the plist file that is created to ensure the 'Name' and 'Version' keys are in line with what you are expecting.
  * The Name key is how the app will appear in the UEM console as well as on the user's Hub Catalog.
2) Upload the pkg and plist files to UEM using the Add Application workflow (Resources > Apps > Native > Internal)
3) Add the icon under Images tab
4) Add the following scripts under the Scripts tab
  * Post Install Script - install Nessus and then link agent, replace the insertKeyHere with your company's key
  ```BASH
  #!/bin/bash
  
  #install nessus
  installer -pkg /usr/local/tmp/Install Nessus Agent.pkg -target /
  
  #link to cloud
  sudo /Library/NessusAgent/run/sbin/nessuscli agent link --key=insertKeyHere –cloud
  ```
  * Post Uninstall Script - ensure app is removed
  ```BASH
  #!/bin/bash

  #Unlink the Nessus agent - Needed in case of upgrade or re-link…
  /Library/NessusAgent/run/sbin/nessuscli agent unlink
  #/Library/NessusAgent/run/sbin/nessuscli fix --set update_hostname=yes
  #/Library/NessusAgent/run/sbin/nessuscli -v

  #remove tag
  rm /private/etc/tenable_tag

  #remove directories
  rm -rf /Library/NessusAgent
  rm -rf /Library/LaunchDaemons/com.tenablesecurity.nessusagent.plist
  rm -rf /Library/PreferencePanes/Nessus\ Agent\ Preferences.prefPane

  #remove service
  sudo launchctl remove com.tenablesecurity.nessusagent

  exit 0
  ```
  * Install Check Script - ensure Nessus Agent is installed and activated. Update the packageVers to what you are deploying
  ```BASH
  #!/bin/bash

  #Variables
  packageVers=8.2.2
  currentVers=$(/Library/NessusAgent/run/sbin/nessuscli --version | awk 'NR==1 {print $3}')

  ##Convert to interger function
  convert_to_integer() {
  echo "$@" | awk -F. '{ printf("%01d%01d%01d\n", $1,$2,$3); }';
  }

  #Print Agent version installed
  echo "Nessus agent version ${currentVers}"

  #Compare the installed version with desired verison
  if [ $(convert_to_integer ${currentVers}) -lt $(convert_to_integer ${packageVers}) ]; then
  echo Install Nessus agent
  exit 0
  else
  echo Nessus Agent Installed
  exit 1
  fi
  ```

## Required Changes/Updates

None

## Change Log

- 2022-06-09: Created Initial File
