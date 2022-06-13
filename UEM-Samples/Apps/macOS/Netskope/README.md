# Netskope

## Overview

- **Authors**: Matt Zaske
- **Email**: mzaske@vmware.com
- **Date Created**: 6/13/2022
- **Supported Platforms**: Workspace ONE UEM v2203
- **Tested on macOS Versions**: macOS Big Sur

## Purpose

Deploying Netskope Client for macOS with Workspace ONE UEM

1) Deploy configuration profile with all the needed payloads
2) Deploy Sensor to map user's email address to the device
3) Obtain the Netskope Client application
4) Parse the pkg with the [Workspace ONE Admin Assistant](https://awagent.com/AdminAssistant/VMwareAirWatchAdminAssistant.dmg)
5) Modify the generated plist file as instructed.
6) Upload the pkg, plist, and icon to Workspace ONE UEM as an Internal App (Resources > Apps > Native > Internal)
7) In the __Scripts__ tab, add the scripts described.
8) Configure any remaining deployment settings and Assign the app as appropriate.

  > **NOTE:** Further info from Netskope can be seen here: https://docs.netskope.com/en/netskope-client-overview-178472.html 

## Profile Deployment Details

In order to deploy Netskope successfully there is a need to deploy a configuration profile with the necessary payloads (VPN, System Extension, and Credentials):

1) Click **Add > Profile > macOS > Device** and complete the General information
2) Select the **System Extensions** payload and click configure
3) Complete the payload (Allow User Overrides can be selected or not, up to the organization), and include the following information in the *Allowed System Extensions* list:
  - Team ID  | Bundle ID
    ------------- | -------------
    24W52P9M7W  | com.netskope.client.Netskope-Client.NetskopeClientMacAppProxy
    24W52P9M7W  |  com.netskope.client.Netskope-Client.NetskopeClientMacDNSProxy
4) Include the following information in the *Allowed System Extension Types* list:
  - Team ID: 24W52P9M7W
  - Select the box for "Network"
5) Final product for System Extensions should look like:
  - <img width="944" alt="image" src="https://user-images.githubusercontent.com/63124926/173423792-d15d2f5a-373e-49ce-a7e5-9a370f82dd13.png">
6) Select the **VPN** payload and click configure
7) Use the following details:
 - Connection Name: Any Name You Like
 - Connection Type: Custom SSL
 - Identifier: com.netskope.client.Netskope-Client
 - Server: Your Netskope Gateway hostname
 - Per-App VPN Rules: Selected
 - Provider Type: AppProxy
 - Provider Designated Requirement: anchor apple generic and identifier"com.netskope.client.Netskope-Client" and (certificateleaf[field.1.2.840.113635.100.6.1.9] /* exists */ or certificate1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificateleaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificateleaf[subject.OU] = "24W52P9M7W")
 - <img width="954" alt="image" src="https://user-images.githubusercontent.com/63124926/173426506-3dc92b33-0faf-44b8-a34a-b640b4dd64c3.png">
8) Select the **Credentials** payload and click configure
9) Select the "Upload" option and upload your root certificate that is downloaded from the Netskope Console (Settings > Security Cloud Platform > MDM Distribution)
  - Select the "+" button in lower right so that you are able to upload a second certificate
  - Select the "Upload" option and upload your tenant certificate that is also downloaded from the Netskope Console
10) Save and publish the profile

## Sensor Deployment Details

1) Add a new Sensor by navigating to Resources>Sensors>Add>macOS
2) IN the General tab, provide the Name as user_email
  - This is important as this name must match the name used in pre-install script in the next section
3) Select Next and provide the following code (leave all other options as default values):
  ```BASH
  #!/bin/bash

  # use lookup value to get eamil address of enrolled user
  echo "$email"

  exit 0
  ```
4) Select Next and configure Variables section to match below:
  - <img width="1293" alt="image" src="https://user-images.githubusercontent.com/63124926/173449355-cbd765c7-1cc5-452d-88eb-fd9c242d1125.png">
5) Select Save & Assign
6) Assign out to proper smart group for Netskope users and set the Trigger to "Periodically"
7) Select Save

## Package Deployment Details

After obtaining the correct package from Netskope directly, you will parse the pkg using the Admin Assistant. After that follow the below steps:
1) Edit the plist file that is created to ensure the 'Name' and 'Version' keys are in line with what you are expecting.
  * The Name key is how the app will appear in the UEM console as well as on the user's Hub Catalog.
2) Upload the pkg and plist files to UEM using the Add Application workflow (Resources > Apps > Native > Internal)
3) Add the icon under Images tab
4) Add the following scripts under the Scripts tab
  * Pre Install Script - Standard Mode (email-based), fill in the tenantURL and restAPI key with your information (lines 7 and 8)
  ```BASH
  #!/bin/bash

  #initialize variables
  TEMP_BRANDING_DIR="/tmp/nsbranding"
  NSINSTPARAM_JSON_FILE="$TEMP_BRANDING_DIR/nsinstparams.json"
  NSUSERCONFIG_JSON_FILE="/Library/Application Support/Netskope/STAgent/nsuserconfig.json"
  tenantURL="your.netskopeserver.com"
  restAPI="API_KEY_HERE"

  #trigger email sensor to ensure value is returned
  sudo /usr/local/bin/hubcli sensors --trigger user_email

  #user info
  emailAddress=""
  currentUser=$(stat -f%Su /dev/console)
  emailAddress=$(sudo /usr/local/bin/hubcli sensors --list | /usr/bin/grep user_email | /usr/bin/awk '{ print $10 }')

  if [ "$emailAddress" != "" ]; then
    #add values to json file
    mkdir -p $TEMP_BRANDING_DIR
    rAPI=$(openssl enc -base64 -d <<< $restAPI)

    echo "{\"TenantHostName\":\"$tenantURL\", \"Email\":\"$emailAddress\", \"RestApiToken\":\"$rAPI\"}" > "${NSINSTPARAM_JSON_FILE}"

    exit 0
  else
    #email not found do not install
    echo "No email address found"
    exit 1
  fi
  ```
  * Post Install Script - launches Netskope client for all users
  ```BASH
  #!/bin/bash

  logged_in_user=$(users)

  #launch UI plist for user
  for user in ${logged_in_user}; do
      user_uid=$(id -u $user)
      echo "Launching UI for $user with uid: $user_uid"
      launchctl bootstrap gui/$user_uid/Library/LaunchAgents/com.netskope.stagentui.plist
      launchctl enable gui/$user_uid/com.netskope.client.stagentui
      launchctl kickstart gui/$user_uid/com.netskope.client.stagentui
  done

  exit 0
  ```
  * Post Uninstall Script - ensure app is removed
  ```BASH
  #!/bin/bash

  /Applications/Remove\ Netskope\ Client.app/Contents/MacOS/Remove\ Netskope\ Client uninstall_me
  rm -rf /Applications/Netskope\ Client.app

  exit 0
  ```
  * Install Check Script - ensure Netskope is installed and proper version activated. Update the target version to what you are deploying in first line
  ```BASH
  #!/bin/bash

  # version of Netskope being deployed
  target_version=84.2.2.576

  # Check if Netskope is installed First
  if [ -d "/Applications/Netskope Client.app" ]; then

    #convert version number to individual
    function version { echo "$@" | /usr/bin/awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

    # grab current version of Netskope
    current_version=$(/usr/bin/defaults read /Applications/Netskope\ Client.app/Contents/Info.plist CFBundleShortVersionString)
    echo current version: $current_version

    # Compare with the version we want to install
    if [ $(version $current_version) -lt $(version $target_version) ]; then
      # version installed is less than target - install
      echo Install Netskope
      exit 0
    else
      # version installed is same or greater than target - mark installed
      echo Netskope is installed
      exit 1
    fi
  else
    # Netskope is not installed - need to install
    echo Install Netskope
    exit 0
  fi
  ```

## Required Changes/Updates

None

## Change Log

- 2022-06-13: Created Initial File
