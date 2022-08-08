#!/bin/bash
##################################
#
#
# Redeveloped by: Matt Zaske
# Originally developed by: John Richards, Daniel Kim, Sanjay Raveendar and Leon Letto
# Copyright 2022 VMware Inc.
#
# macOS Migrator
# This script orchestrates the migration process of a macOS device from one management
# system to another. It is designed to be used with DEPNotify.
#
#
##################################

#set Variables
WorkspaceServicesProfile="Workspace Services"
DeviceManagerProfile="Device Manager"
migratorlog="/var/log/vmw_migrator.log"
depnotifylog="/private/var/tmp/depnotify.log"
depnotifypath="/Applications/Utilities/DEPNotify.app"
hubpath="https://packages.vmware.com/wsone/VMwareWorkspaceONEIntelligentHub.pkg"
migratorpath="/Library/Application Support/VMware/migrator.sh"
resourcesdir="/Library/Application Support/VMware/MigratorResources"
hubDLpath="/private/var/tmp/hub.pkg"
ldpath="/Library/LaunchDaemons/com.vmware.migrator.plist"
ldidentifier="com.vmware.migrator"
currentOS=$(sw_vers -productVersion)
currentUser=$(stat -f%Su /dev/console)
currentUID=$(id -u "$currentUser")
#customization Scripts
predepnotifyScript="/Library/Application Support/VMware/MigratorResources/predepnotify.sh"
premigrationScript="/Library/Application Support/VMware/MigratorResources/premigration.sh"
midmigrationScript="/Library/Application Support/VMware/MigratorResources/midmigration.sh"
postmigrationScript="/Library/Application Support/VMware/MigratorResources/postmigration.sh"

######## Functions ########

# Logging Function for reporting actions
log(){
    DATE=`date +%Y-%m-%d\ %H:%M:%S`
    LOG="$migratorlog"

    echo "$DATE [Migrator]" " $1" >> $LOG
}

# writing actions to depnotify log to control depnotify
depnotify() {
  log "[DEPNotify] $1"
  #write to depnotifylog
  echo "$1" >> $depnotifylog
}

#convert version number to individual
function version { echo "$@" | /usr/bin/awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

# clean up migrator files and exit
cleanup() {
  log "Cleaning up... DEPNotify.app will not be removed..."
  log "Attempting to delete LaunchDaemon plist: $ldpath"
  /bin/rm -f "$ldpath"

  log "Attempting to delete Migrator script: $migratorpath"
  /bin/rm -f "$migratorpath"

  log "Attempting to delete Migrator Resources directory: $resourcesdir"
  /bin/rm -rf "$resourcesdir"

  log "Attempting to delete DEPNotify log: $depnotifylog"
  /bin/rm -f "$depnotifylog"

  log "Attempting to remove LaunchDaemon from launchctl: $ldpath"
  /bin/launchctl remove "$ldpath"

  log "Cleanup done. Exiting........"
  exit 0
}

# grab all relevant device info
getDeviceInfo() {
  spFile="/tmp/SPHardwareDataType.plist"
  /usr/sbin/system_profiler -xml SPHardwareDataType > "$spFile"
  serial=$(/usr/libexec/PlistBuddy -c "Print :0:_items:0:serial_number" "$spFile")
  deviceType=$(/usr/libexec/PlistBuddy -c "Print :0:_items:0:machine_name" "$spFile")
  deviceModel=$(/usr/libexec/PlistBuddy -c "Print :0:_items:0:machine_model" "$spFile")
  deviceUUID=$(/usr/libexec/PlistBuddy -c "Print :0:_items:0:platform_UUID" "$spFile")
  /bin/rm -f "$spFile"
}

# prompt user to input data - username, email
init_registration() {
  # delete registration done file if it exists
  /bin/rm -f /var/tmp/com.depnotify.registration.done
  # create plist for setup Registration fields in ~/Library/Preferences/menu.nomad.DEPNotify.plist
  sudo -u $currentUser defaults write menu.nomad.DEPNotify pathToPlistFile /Users/Shared/UserInput.plist
  sudo -u $currentUser defaults write menu.nomad.DEPNotify registrationButtonLabel "Continue"

  if [[ "$promptType" = "username" ]]; then
    sudo -u $currentUser defaults write menu.nomad.DEPNotify registrationMainTitle "Enter your username"
    sudo -u $currentUser defaults write menu.nomad.DEPNotify textField1Label "Username"
    sudo -u $currentUser defaults write menu.nomad.DEPNotify textField1RegexPattern '[A-Z0-9a-z.-_@]'
  else
    sudo -u $currentUser defaults write menu.nomad.DEPNotify registrationMainTitle "Enter your email"
    sudo -u $currentUser defaults write menu.nomad.DEPNotify textField1Label "Email"
    sudo -u $currentUser defaults write menu.nomad.DEPNotify textField1RegexPattern '[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}'
  fi
}

# wait for user input
wait_for_input() {
  path="/Users/Shared/UserInput.plist"
  done="/var/tmp/com.depnotify.registration.done"
  runcount=0
  value=""
  log "Waiting for user input..."
  while [ $runcount -lt 300 ]
  do
    if [[ -f "$done" ]]; then
      if [[ "$promptType" = "username" ]]; then
        value=$(/usr/libexec/PlistBuddy -c "Print Username" "$path")
        log "User entered $value for username"
        break
      else
        #prompt user for Email
        value=$(/usr/libexec/PlistBuddy -c "Print Email" "$path")
        log "User entered $value for email"
        break
      fi
    else
      runcount=$((runcount+1))
      sleep 2 # 300 tries every 2 seconds = 600seconds = 10 minute timeout
    fi
  done

  if [[ "$value" = "" ]]; then
    #value is null - exit
    depnotify "Status: Migration has failed - Timeout after no input received."
    log "Migration has failed - Timeout after no input received."
    depnotify "Command: WindowStyle: Activate"
    depnotify "Command: Quit: Migration has failed - Timeout after no input received."
    cleanup
  fi
  echo "$value"
}

# search for user in WS1 and then register device to user
registerDeviceWS1() {
  #check if prompt requested
  if [[ "$registrationType" = "prompt" ]]; then
    init_registration
    if [[ "$promptType" = "username" ]]; then
      username=$(wait_for_input)
    else
      #prompt user for Email
      useremail=$(wait_for_input)
    fi
  else
    #use local username
    log "Registration type set to local"
    log "Using $currentUser for enrollment username"
    username="$currentUser"
  fi

  #query WS1 for user info
  depnotify "Status: Validating user for migration"
  if [[ "$promptType" = "email" ]]; then
    #api search user by email
    url="$apiurl/api/system/users/search?email=$useremail"
    log "Querying server for ID for $useremail"
    log "GET - $url"
  else
    #api search user by username
    url="$apiurl/api/system/users/search?username=$username"
    log "Querying server for ID for $username"
    log "GET - $url"
  fi
  #make API call
  response=$(/usr/bin/curl -X GET $url -H "Authorization: $dest_auth" -H "aw-tenant-code: $dest_token" -H  "accept: application/json" -H "Content-Type: application/json")
  log "Raw Response: $response"

  #check if multiple matches
  userID=""
  userCount=$(echo $response | /usr/local/bin/jq -r '.Total')
  if [[ $userCount -gt 1 ]]; then
    index=0
    while [ $index -lt $userCount ]
    do
      userArray=$(echo $response | /usr/local/bin/jq -r ".Users[$index].UserName")
      emailArray=$(echo $response | /usr/local/bin/jq -r ".Users[$index].Email")
      if [[ "$username" == "$userArray" ]]; then
        userID=$(echo $response | /usr/local/bin/jq -r ".Users[$index].Id.Value")
        username="$userArray"
        break
      elif [[ "$useremail" == "$emailArray" ]]; then
        userID=$(echo $response | /usr/local/bin/jq -r ".Users[$index].Id.Value")
        username="$userArray"
        break
      fi
      index=$((index+1))
    done
  else
    userID=$(echo $response | /usr/local/bin/jq -r ".Users[0].Id.Value")
  fi

  #check if no user found - exit
  if [[ "$userID" == "" || -z "$userID" ]]; then  # if the above parsing comes back with nothing, quit
    log "Unknown WSONE User ID"
    depnotify "Command: WindowStyle: Activate"
    depnotify "Command: Quit: Unable to find user in WSONE, quitting..."
    cleanup
  fi
  #create registration entry to ws1
  log "User $username UserID is $userID"
  depnotify "Status: Registering device and getting enrollment token from Workspace ONE UEM..."
  registration='{"PlatformId":10, "MessageType":0, "ToEmailAddress":"noreply@vmware.com", "Ownership":"C", "LocationGroupId":"'$groupid'", "SerialNumber":"'$serial'", "FriendlyName":"'$username' '$deviceType'"}'

  log "Registering device with..."
  log "$registration"
  url="$apiurl/api/system/users/$userID/registerdevice"
  log "POST - $url"

  response=$(/usr/bin/curl -X POST $url -H "Authorization: $dest_auth" -H "aw-tenant-code: $dest_token" -H  "accept: application/json" -H "Content-Type: application/json" -d "$registration")
  #check if successful
  if [[ ! -z "$response" ]]; then
    #api failed
    log "Failed - Reason: $response"
    depnotify "Command: WindowStyle: Activate"
    depnotify "Command: Quit: Unable to register device with WSONE"
    cleanup
  fi
}

# unenroll device from ws1
removeWS1() {
  log "Removing Workspace ONE UEM"
  depnotify "Status: Unenrolling from previous Workspace ONE UEM environment"
  /bin/bash /Library/Scripts/hubuninstaller.sh
  /bin/rm -rf "/Library/Application Support/AirWatch/"
  # API Call to enterprise wipe device
  url="$originurl/api/mdm/devices/commands?command=EnterpriseWipe&searchBy=Serialnumber&id=$serial"
  log "POST - $url"
  response=$(/usr/bin/curl -X POST $url -H "Authorization: $origin_auth" -H "aw-tenant-code: $origin_token" -H  "accept: application/json" -H "Content-Type: application/json" -H "Content-Length: 0")
  #check if successful
  if [[ ! -z "$response" ]]; then
    #api failed
    log "Failed - Reason: $response"
    depnotify "Command: WindowStyle: Activate"
    depnotify "Command: Quit: Unable to unenroll device from WSONE"
    cleanup
  fi
}

# verify device is unenrolled
waitForUnenroll() {
  #check for MDM profile installed
  mdmProfile=$(/usr/bin/profiles -vP | /usr/bin/grep "com.apple.mdm")
  if [[ ! -z "$mdmProfile" ]]; then
    runcount=0
    log "Device is enrolled - com.apple.mdm payload found"
    while [ $runcount -lt 270 ]
    do
      mdmProfile=$(/usr/bin/profiles -vP | /usr/bin/grep "com.apple.mdm")
      if [[ ! -z "$mdmProfile" ]]; then
        log "Still enrolled, waiting for unenrollment..."
        #try force removing profiles
        # Get a list from all profiles installed on the computer and remove every one of the
        for identifier in $(sudo /usr/bin/profiles -L | awk "/attribute/" | awk '{print $4}')
        do /usr/bin/profiles -R -p "$identifier"
        done
        # same thing for user context
        for identifier in $(sudo -u "$currentUser" /usr/bin/profiles -L | awk "/attribute/" | awk '{print $4}')
        do sudo -u $currentUser /usr/bin/profiles -R -p "$identifier"
        done
      else
        log "Unenrollment detected - no com.apple.mdm payload found"
        echo "no"
        return
      fi
      runcount=$((runcount+1))
      sleep 2 # 270 tries every 2 seconds = 540 seconds = 9 minute timeout
    done
    echo "enrolled"
  else
    log "Device is not enrolled - no com.apple.mdm payload found"
    echo "no"
  fi
}

# enroll to WS1
enrollWS1() {
  #trigger install of MDM profile and launch sys prefs for user
  depnotify "Command: WindowStyle: Activate"
  depnotify "Status: Please proceed through the System Prompts to install the enrollment profile"
  log "Opening profile to begin enrollment"
  if [[ $(version "$currentOS") -ge $(version "11.0") ]]; then
    sudo -u "$currentUser" /usr/bin/open "$enrollmentProfilePath"
    sudo -u "$currentUser" /usr/bin/open -b com.apple.systempreferences /System/Library/PreferencePanes/Profiles.prefPane
  elif [[ $(version "$currentOS") -ge $(version "10.15.1") ]]; then
    sudo -u "$currentUser" /usr/bin/open -a /System/Applications/System Preferences.app "$enrollmentProfilePath"
  else
    sudo -u "$currentUser" /usr/bin/open -a /Applications/System Preferences.app "$enrollmentProfilePath"
  fi
}

# verify enrollment
verifyEnrollment() {
  #ensure the MDM profile is installed, if not call enrollWS1 again to prompt user
  runcount=0
  while [ $runcount -lt 180 ]
  do
    mdmProfile=$(/usr/bin/profiles -vP | /usr/bin/grep "$WorkspaceServicesProfile\|$DeviceManagerProfile")
    if [[ ! -z "$mdmProfile" ]]; then
      log "Successfully Enrolled - Workspace ONE MDM profile detected"
      echo "enrolled"
      return
    else
      log "MDM profile not found, checking again..."
      if [[ $runcount -eq 45 || $runcount -eq 90 || $runcount -eq 135 || $runcount -eq 180 ]]; then
        #trigger profile install again
        enrollWS1
      fi
    fi
    runcount=$((runcount+1))
    sleep 3 # 180 tries every 3 seconds = 540 seconds = 9 minute timeout
  done
  echo "no"
}

# download and install ws1 intelligent hub
hubInstall() {
  log "Downloading Workspace ONE Intelligent Hub..."
  depnotify "Status: Downloading Workspace ONE Intelligent Hub..."
  #download hub
  log "Hub download location: $hubpath"
  response=$(/usr/bin/curl -o "$hubDLpath" $hubpath)
  if [[ ! -f  "$hubDLpath" ]]; then
    #download failed
    log "Failed - Error downloading Workspace ONE Intelligent Hub."
    depnotify "Command: WindowStyle: Activate"
    depnotify "Status: Error downloading Workspace ONE Intelligent Hub. Download manually from getwsone.com."
    depnotify "Command: Quit: Your device is now migrated."
    cleanup
  fi
  #install hub
  log "Installing Workspace ONE Intelligent Hub..."
  depnotify "Status: Installing Workspace ONE Intelligent Hub..."
  /usr/sbin/installer -pkg "$hubDLpath" -target /
  depnotify "Status: Enrollment complete!"
  sleep 2
  /bin/rm -rf "$hubDLpath"
}

######## main code ########
log "===== Beginning migration run ====="

#read configured Options
if [[ "$1" =~ ^((-{1,2})([Hh]$|[Hh][Ee][Ll][Pp])|)$ ]]; then
  print_usage; exit 1
else
  while [[ $# -gt 0 ]]; do
    opt="$1"
    shift;
    current_arg="$1"
    if [[ "$current_arg" =~ ^-{1,2}.* ]]; then
      echo "WARNING: You may have left an argument blank. Double check your command."
    fi
    case "$opt" in
      "--origin") origin="$1"; shift;;
      "--origin-apiurl") originurl="$1"; shift;;
      "--origin-auth") origin_auth="$1"; shift;;
      "--origin-token") origin_token="$1"; shift;;
      "--removal-script") removalScript="$1"; shift;;
      "--enrollment-profile-path") enrollmentProfilePath="$1"; shift;;
      "--registration-type") registrationType="$1"; shift;;
      "--dest-baseurl") baseurl="$1"; shift;;
      "--dest-auth") dest_auth="$1"; shift;;
      "--dest-token") dest_token="$1"; shift;;
      "--dest-groupid") groupid="$1"; shift;;
      "--dest-apiurl") apiurl="$1"; shift;;
      "--user-prompt") promptType="$1"; shift;;
      *                   ) echo "ERROR: Invalid option: \""$opt"\"" >&2
                            exit 1;;
    esac
  done
fi

#default values if not provided
if [[ "$origin" == "" ]]; then origin="custom"; fi
if [[ "$removalScript" == "" ]]; then removalScript="/Library/Application Support/VMware/MigratorResources/removemdm.sh"; fi
if [[ "$enrollmentProfilePath" == "" ]]; then enrollmentProfilePath="/Library/Application Support/VMware/MigratorResources/*.mobileconfig"; fi
if [[ "$registrationType" == "" ]]; then registrationType="local"; fi
if [[ "$apiurl" == "" ]]; then apiurl="$baseurl"; fi
#change hub path to environment specific
hubpath="$baseurl/DeviceServices/resources/VMwareWorkspaceONEIntelligentHub.pkg"

#log device info
getDeviceInfo
log "Device info- Serial: $serial OS: $currentOS DeviceType: $deviceType DeviceModel: $deviceModel"
log "Current logged in username is: $currentUser UID: $currentUID"

# Create new log file for DEPNotify to watch
log "Initializing DEPNotify Log path at: $depnotifylog"
/bin/rm -f "$depnotifylog"
/usr/bin/touch "$depnotifylog"
/bin/chmod 644 "$depnotifylog"

# run predepnotify_script
/bin/bash "$predepnotifyScript"
sleep 1

# launch depnotify
log "Opening DEPNotify for user: $currentUser"
sudo -u $currentUser /usr/bin/open -a "$depnotifypath"
sleep 3

# register device to user in WS1 destination
if [[ ! "$registrationType" = "none" ]]; then registerDeviceWS1; fi

# run premigration_script
/bin/bash "$premigrationScript"
sleep 1

# remove existing MDM
if [[ "$origin" = "custom" ]]; then
  log "Removing Custom"
  depnotify "Status: Removing prior management"
  /bin/bash "$removalScript"
elif [[ "$origin" = "wsone" ]]; then
  removeWS1
fi

# wait/verify unenrolled
enrollStatus=$(waitForUnenroll)
if [[ "$enrollStatus" = "enrolled" ]]; then
  #device failed to unenroll - quit
  log "Failed - Reason: device is still enrolled to prior MDM"
  depnotify "Command: WindowStyle: Activate"
  depnotify "Status: Unable to remove prior MDM"
  depnotify "Command: Quit: Unable to unenroll device"
  cleanup
fi

#kill sys prefs
sudo -u $currentUser killall "System Preferences"

# run midmigration_script
/bin/bash "$midmigrationScript"
depnotify "Status: Ready to enroll"
sleep 1

# enroll to WS1
enrollWS1
enrollStatus=$(verifyEnrollment)
if [[ "$enrollStatus" = "no" ]]; then
  #device failed to enroll - quit
  log "Failed - Enrollment has failed - MDM Profile not found."
  depnotify "Command: WindowStyle: Activate"
  depnotify "Status: Enrollment has failed - MDM Profile not found."
  depnotify "Command: Quit: Enrollment has failed - MDM Profile not found"
  cleanup
fi

#device enrolled - continue on
# download and install hub
sudo -u $currentUser killall "System Preferences"
depnotify "Command: WindowStyle: Activate"
if [ ! -d "/Applications/Workspace ONE Intelligent Hub.app" ]; then hubInstall; fi

# run postmigration_script
/bin/bash "$postmigrationScript"
sleep 1

#cleanup and exit - reboot if needed
depnotify "Command: WindowStyle: Activate"
depnotify "Command: Quit: Your device is now migrated."
cleanup
