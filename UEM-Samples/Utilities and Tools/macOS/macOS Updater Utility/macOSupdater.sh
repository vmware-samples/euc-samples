#!/bin/bash
##################################
#
#
# Developed by: Matt Zaske
# July 2022
#
# macOS Updater Utility (mUU):
# Designed to keep macOS devices on the desired OS version
# by utilizing Apples MDM commands
#
#
##################################

#set Variables
managedPlist="/Library/Managed Preferences/com.macOSupdater.settings.plist"
counterFile="/private/var/macOSupdater/mu_properties.plist"
logLocation="/Library/Logs/macOSupdater.log"
currentOS=$(sw_vers -productVersion)
currentUser=$(stat -f%Su /dev/console)
currentUID=$(id -u "$currentUser")
serial=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
#variables set via WS1
# $clientID
# $clientSec
# $apiURL
# $tokenURL

### functions

#convert version number to individual
function version { echo "$@" | /usr/bin/awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

# Logging Function for reporting actions
log(){
    DATE=`date +%Y-%m-%d\ %H:%M:%S`
    LOG="$logLocation"

    echo "$DATE" " $1" >> $LOG
}

# generate oAuth token
getToken () {
  #request access token
  oAuthToken=$(/usr/bin/curl -X POST $tokenURL -H  "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=client_credentials&client_id=$1&client_secret=$2")
  oAuthToken=$(echo $oAuthToken | /usr/bin/sed "s/{.*\"access_token\":\"\([^\"]*\).*}/\1/g")
  if [[ -n "$oAuthToken" ]]; then
    log "auth token received"
  else
    log "failed to get API auth token, exiting....."
    exit 0
  fi
  echo "$oAuthToken"
}

# MDM command via api
# $1 - InstallAction, $2 - ProductKey or ProductVersion, $3 - productKey/version data
mdmCommand () {
  # custom MDM command API
  /usr/bin/curl "$apiURL/api/mdm/devices/commands?command=CustomMdmCommand&searchby=SerialNumber&id=$serial" \
  -X POST \
  -H "Authorization: Bearer $authToken" \
  -H "Accept: application/json;version=2" \
  -H "Content-Type: application/json" \
  -d '{"CommandXML" : "<dict><key>RequestType</key><string>ScheduleOSUpdate</string><key>Updates</key><array><dict><key>InstallAction</key><string>'$1'</string><key>'$2'</key><string>'$3'</string></dict></array></dict>"}'
  log "API call sent - serial: $serial, action: $1, type: $2, value: $3"
  echo "command sent"
}

# installer check
dlCheck () {
  #check major or minor update
  if [[ "$1" = "major" ]]; then
    #check for installer file cooresponding to major version number
    log "checking for major update download"
    case $desiredMajor in
      "11")
        # Checking for Big Sur
        if [ -d "/Applications/Install macOS Big Sur.app" ]; then echo "yes"; else echo "no"; fi

        ;;
      "12")
        # Checking for Monterey
        if [ -d "/Applications/Install macOS Monterey.app" ]; then echo "yes"; else echo "no"; fi

        ;;
      "13")
        # Checking for Ventura
        if [ -d "/Applications/Install macOS Ventura.app" ]; then echo "yes"; else echo "no"; fi

        ;;
      *)
        echo "no"
        ;;
    esac
  else
    #find product key of minor update then search if downloaded
    log "checking for minor update download"
    productKey=$(/usr/bin/plutil -p /Library/Updates/ProductMetadata.plist | /usr/bin/grep -w -A 2 "$desiredOS" | /usr/bin/awk 'NR==3{print $3}' | /usr/bin/tr -d '"')
    updatePath=$(/usr/bin/find /private/var/folders/zz -type d -name "*$productKey*" 2>/dev/null | grep "swcdn.apple.com")
    log "OSproductKey: $productKey"
    log "Update Path: $updatePath"
    if [ -d "$updatePath" ]; then
      echo "yes"
    else
      #update not found
      echo "no"
    fi
  fi
}

# download installer
dlInstaller () {
  #check major or minor update
  if [[ "$1" = "major" ]]; then
    #download major OS Installer
    /usr/sbin/softwareupdate --fetch-full-installer --full-installer-version "$desiredOS" &
  else
    #check if need to use ProductKey or ProductVersion (macOS 12+) in MDM command
    if [[ "$currentMajor" -ge "12" ]]; then
      #use productVersion
      log "mdmCommand DownloadOnly ProductVersion $desiredOS"
      mdmCommand "DownloadOnly" "ProductVersion" "$desiredOS"
    else
      #use productKey
      log "mdmCommand DownloadOnly ProductKey $desiredProductKey"
      mdmCommand "DownloadOnly" "ProductKey" "$desiredProductKey"
    fi
  fi
  echo "Downloading"
}

# prompt user
userPrompt () {
  #collect info from settings plist
  title=$(/usr/libexec/PlistBuddy -c "Print :messageTitle" "$managedPlist")
  message=$(/usr/libexec/PlistBuddy -c "Print :messageBody" "$managedPlist")
  icon=$(/usr/libexec/PlistBuddy -c "Print :messageIcon" "$managedPlist")
  promptTimer=$(/usr/libexec/PlistBuddy -c "Print :promptTimer" "$managedPlist")
  deferrals=$((maxDeferrals-deferralCount))
  # $1 will tell us if deferral button should be present
  if [[ "$1" = "deferral" ]]; then
    #prompt user with buttons and deferral info
    prompt=$(/bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$message \n\nYou have $deferrals deferrals remaining before the upgrade will automatically commence.\" with title \"$title\" with icon POSIX file \"$icon\" buttons {\"Defer\", \"Upgrade\"} default button 2 giving up after $promptTimer")
  else
    #prompt user with no buttons - message that upgrade is commencing, save all work and close all apps
    prompt=$(/bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$message \n\nThe upgrade will begin momentarily. Please save any work and close all applications.\" with title \"$title\" with icon POSIX file \"$icon\" buttons {\"Upgrade\"} default button 1 giving up after 300")
  fi
  echo "$prompt"
}

# install OS update
installUpdate () {
  #check major or minor update
  if [[ "$1" = "major" ]]; then
    #install major update
    #check if need to use ProductKey or ProductVersion (macOS 12+) in MDM command
    if [[ "$currentMajor" -ge "12" ]]; then
      #use productVersion
      log "mdmCommand InstallForceRestart ProductVersion $desiredOS"
      mdmCommand "InstallForceRestart" "ProductVersion" "$desiredOS"
    else
      #use productKey - check intel vs apple silicon as well
      cpuType=$(/usr/sbin/sysctl -n machdep.cpu.brand_string | grep -o "Intel")
      if [[ -n "$cpuType" ]]; then
        #intel - use startosinstall
        log "Triggering update with startosinstall"
        case $desiredMajor in
          "11")
            /Applications/Install\ macOS\ Big\ Sur.app/Contents/Resources/startosinstall --agreetolicense --nointeraction --forcequitapps &
            ;;
          "12")
            /Applications/Install\ macOS\ Monterey.app/Contents/Resources/startosinstall --agreetolicense --nointeraction --forcequitapps &
            ;;
          "13")
            /Applications/Install\ macOS\ Ventura.app/Contents/Resources/startosinstall --agreetolicense --nointeraction --forcequitapps &
            ;;
          *)
            echo "unknown major version"
            ;;
        esac
      else
        #apple silicon - use MDM commands
        log "mdmCommand InstallForceRestart ProductKey $desiredProductKey"
        mdmCommand "InstallForceRestart" "ProductKey" "$desiredProductKey"
      fi
    fi
  else
    #install minor update
    #check if need to use ProductKey or ProductVersion (macOS 12+) in MDM command
    if [[ "$currentMajor" -ge "12" ]]; then
      #use productVersion
      log "mdmCommand InstallForceRestart ProductVersion $desiredOS"
      mdmCommand "InstallForceRestart" "ProductVersion" "$desiredOS"
    else
      #use productKey
      log "mdmCommand InstallForceRestart ProductKey $desiredProductKey"
      mdmCommand "InstallForceRestart" "ProductKey" "$desiredProductKey"
    fi
  fi
  /bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"The update is now installing.  Your device will be rebooted momentarily. Please save any work and close all applications.\" with title \"Installation in Progress...\" with icon POSIX file \"$icon\" buttons {\"OK\"} default button 1" &
  echo "Installing"
}

### main code
log "===== Launching macOS Updater Utility ====="

#check if user is logged in
if [[ "$currentUser" = "root" ]]; then exit 0; fi
log "$currentUser is logged in"

#check if settings profile is Installed
if [ ! -f "$managedPlist" ]; then
  #clean up counter file and Exit
  rm -rf "$counterFile"
  log "config profile not installed, exiting....."
  exit 0
fi
log "profile installed"

#check if mac is already on desired version or higher
desiredOS=$(/usr/libexec/PlistBuddy -c "Print :desiredOSversion" "$managedPlist")
if [[ $(version $currentOS) -ge $(version $desiredOS) ]]; then
  #clean up counter file and Exit
  rm -rf "$counterFile"
  log "device is up to date, exiting....."
  exit 0
fi
log "upgrade needed - currentOS: $currentOS : desiredOS: $desiredOS"

#check if properties file has been created, if not create it
if [ ! -f "$counterFile" ]; then
   /usr/bin/defaults write "$counterFile" deferralCount -int 0
fi
deferralCount=$(/usr/libexec/PlistBuddy -c "Print deferralCount" "$counterFile")
maxDeferrals=$(/usr/libexec/PlistBuddy -c "Print maxDeferrals" "$managedPlist")
log "counter present"

#check if major update or minor
currentMajor=$(echo $currentOS | /usr/bin/cut -f1 -d ".")
desiredMajor=$(echo $desiredOS | /usr/bin/cut -f1 -d ".")
if [ $currentMajor -lt $desiredMajor ]; then updateType="major"; else updateType="minor"; fi
log "$updateType update requested"

#grab desired product key if needed - currentOS < 12.0
#check major or minor
if [ $currentMajor -lt 12 ]; then
  if [[ "$1" = "major" ]]; then
    desiredProductKey="MACOS_"$desiredOS
  else
    desiredProductKey="MSU_UPDATE_"$osBuild"_patch_"$desiredOS
  fi
  log "ProductKey: $desiredProductKey"
fi

#grab API info
authToken=$(getToken $clientID $clientSec)

#check if update has downloaded, if not trigger download and exit
downloadCheck=$(dlCheck "$updateType")
if [[ "$downloadCheck" = "no" ]]; then
  dlInstaller "$updateType"
  log "installer download started, exiting....."
  exit 0
fi
log "installer downloaded"

log "deferrals: $deferralCount"
log "maxDeferrals: $maxDeferrals"
#prompt user to upgrade
#check if user has deferrals remaining
if [[ $deferralCount -lt  $maxDeferrals ]]; then
  #prompt user to upgrade with deferral option
  log "prompting user with deferral"
  userReturn=$(userPrompt "deferral")
  #check user response
  if [ "$userReturn" = "button returned:Upgrade, gave up:false" ]; then
    #trigger update and exit
    log "installing update"
    installUpdate "$updateType"
  else
    #increase deferral count and exit
    log "user deferred"
    deferralCount=$((deferralCount+1))
    /usr/bin/defaults write "$counterFile" deferralCount -int $deferralCount
  fi
else
  #prompt user that upgrade will take place momentarily - close out of all programs, save work, etc.
  log "prompting user without deferral"
  userPrompt "force"
  #trigger update
  log "installing update"
  installUpdate "$updateType"
fi

log ">>>>> Exiting macOS Updater Utility <<<<<"
exit 0
