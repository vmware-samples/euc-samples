#!/bin/bash
##################################
#
#
# Developed by: Matt Zaske
# July 2022
#
# revision 3 (September 1, 2022)
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
ws1Log="/Library/Application Support/AirWatch/Data/ProductsNew/"
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
log() {
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
    /bin/cp "$logLocation" "$ws1Log"
    exit 0
  fi
  echo "$oAuthToken"
}

# MDM command via api
# $1 - InstallAction, $2 - ProductKey or ProductVersion, $3 - productKey/version data
mdmCommand () {
  # custom MDM command API
  resppnse=$(/usr/bin/curl "$apiURL/api/mdm/devices/commands?command=CustomMdmCommand&searchby=SerialNumber&id=$serial" \
  -X POST \
  -H "Authorization: Bearer $authToken" \
  -H "Accept: application/json;version=2" \
  -H "Content-Type: application/json" \
  -d '{"CommandXML" : "<dict><key>RequestType</key><string>ScheduleOSUpdate</string><key>Updates</key><array><dict><key>InstallAction</key><string>'$1'</string><key>'$2'</key><string>'$3'</string></dict></array></dict>"}')
  log "API call sent - serial: $serial, action: $1, type: $2, value: $3"
  log "API Response: $response"
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
    #find minor update then search if downloaded
    log "checking for minor update download"
    #check directory exists
    dirCount=$(find /System/Library/AssetsV2/com_apple_MobileAsset_MacSoftwareUpdate -maxdepth 1 -type d | /usr/bin/wc -l)
    if [[ "$dirCount" -gt 1 ]]; then
      #check for matching OS version
      index=1
      while [ $index -lt $dirCount ]
      do
        index=$((index+1))
        updateDir=$(find /System/Library/AssetsV2/com_apple_MobileAsset_MacSoftwareUpdate -maxdepth 1 -type d | /usr/bin/awk 'NR=='$index'{print}')
        msuPlist="$updateDir/Info.plist"
        msuOSVersion=$(/usr/libexec/PlistBuddy -c "Print :MobileAssetProperties:OSVersion" "$msuPlist")
        echo "$msuOSVersion"
        if [[ $(version $msuOSVersion) -eq $(version $desiredOS) ]];  then
          log "Download found"
          echo "yes"
          return
        fi
      done
      log "Download found but not correct"
      echo "no"
    else
      #download not started
      log "Download not found"
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

# secondary prompt to inform user of major update install progress
installStatus () {
  #create script and call it to notify user update is installing and reboot coming
  /bin/cat <<"EOT" > installStatus.sh
  #!/bin/bash

  #notify user that migration is underway - intelligent hub is downloading and installing
  alertText="macOS Update Installation In Progress..."
  alertMessage="The macOS Update is now being prepared. Please save any work and close all applications as your Mac will be rebooted as soon as it has completed installation."
  currentUser=$(stat -f%Su /dev/console)
  currentUID=$(id -u "$currentUser")
  installLog="/private/var/log/install.log"
  /bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$alertMessage\" with title \"$alertText\" with icon stop buttons {\"OK\"}" &
  updateProgress=$(/usr/bin/grep -e "Progress: phase:PREPARING_UPDATE stalled:NO portionComplete:" "$installLog" | /usr/bin/awk 'END{print substr($8,19,2)}')
  updatePrepDone=$(/usr/bin/grep -e "Progress: phase:COMPLETED stalled:NO portionComplete:1.000000" "$installLog")

  #report update prep %
  count=0
  while [ -z "$updatePrepDone" ]
  do
    updateProgress=$(/usr/bin/grep -e "Progress: phase:PREPARING_UPDATE stalled:NO portionComplete:" "$installLog" | /usr/bin/awk 'END{print substr($8,19,2)}')
    updatePrepDone=$(/usr/bin/grep -e "Progress: phase:COMPLETED stalled:NO portionComplete:1.000000" "$installLog")
    #display progress
    interval=$(( count % 180 ))
    if [[ ! -z "$updateProgress" && "$interval" -eq 0 ]]; then
      alertText="macOS Update Installation In Progress..."
      alertMessage="The macOS Update is now installing. Please save any work and close all applications as your Mac will be rebooted as soon as it has completed installation.\n\n Percentage Complete: $updateProgress%"
      /bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$alertMessage\" with title \"$alertText\" with icon stop buttons {\"OK\"} giving up after 60" &
    fi
    #wait - timeout after 60 minutes
    if [[ $count -eq 3600 ]]; then
      echo "update failed to prep"
      alertText="macOS Update Failed"
      alertMessage="The macOS Update failed to install. The installation will be retried at a later time. Please reach out to your IT helpdesk if you have any questions."
      /bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$alertMessage\" with title \"$alertText\" with icon stop buttons {\"OK\"}" &
      exit 0
    fi
    count=$((count+1))
    sleep 1
  done

  #done - reboot
  count=0
  updateSuccess=$(/usr/bin/grep -e "Apply succeeded, proceeding with reboot" "$installLog")
  while [ -z "$updateSuccess" ]
  do
    updateSuccess=$(/usr/bin/grep -e "Apply succeeded, proceeding with reboot" "$installLog")
    #wait - timeout after 10 minutes
    if [[ $count -eq 600 ]]; then
      echo "update failed to prep"
      alertText="macOS Update Failed"
      alertMessage="The macOS Update failed to install. The installation will be retried at a later time. Please reach out to your IT helpdesk if you have any questions."
      /bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$alertMessage\" with title \"$alertText\" with icon stop buttons {\"OK\"}" &
      exit 0
    fi
    count=$((count+1))
    sleep 1
  done
  alertText="macOS Update Installation In Progress..."
  alertMessage="The macOS Update is now installed. Your device will now reboot."
  /bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$alertMessage\" with title \"$alertText\" with icon stop buttons {\"OK\"}" &
EOT

  /bin/bash installStatus.sh &
}

# install OS update
installUpdate () {
  #check major or minor update
  if [[ "$1" = "major" ]]; then
    #install major update
    #check if need to use ProductKey or ProductVersion (macOS 12+) in MDM command
    if [[ "$currentMajor" -ge "12" ]]; then
      #use productVersion
      log "mdmCommand InstallASAP ProductVersion $desiredOS"
      mdmCommand "InstallASAP" "ProductVersion" "$desiredOS"
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
        log "mdmCommand InstallASAP ProductKey $desiredProductKey"
        mdmCommand "InstallASAP" "ProductKey" "$desiredProductKey"
      fi
    fi
    #trigger script to notify user that upgrade is installing and reboot is imminent
    log "triggering notification script"
    installStatus
  else
    #install minor update
    #check if need to use ProductKey or ProductVersion (macOS 12+) in MDM command
    if [[ "$currentMajor" -ge "12" ]]; then
      #use productVersion
      log "mdmCommand InstallForceRestart ProductVersion $desiredOS"
      mdmCommand "InstallForceRestart" "ProductVersion" "$desiredOS"
      #sleep 1 minute and InstallASAP if update not already started
      sleep 60
      log "mdmCommand InstallASAP ProductVersion $desiredOS"
      mdmCommand "InstallASAP" "ProductVersion" "$desiredOS"
    else
      #use productKey
      log "mdmCommand InstallForceRestart ProductKey $desiredProductKey"
      mdmCommand "InstallForceRestart" "ProductKey" "$desiredProductKey"
      #sleep 1 minute and InstallASAP if update not already started
      sleep 60
      log "mdmCommand InstallASAP ProductKey $desiredProductKey"
      mdmCommand "InstallASAP" "ProductKey" "$desiredProductKey"
    fi
  fi
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
  /bin/cp "$logLocation" "$ws1Log"
  exit 0
fi
log "profile installed"

#check if mac is already on desired version or higher
desiredOS=$(/usr/libexec/PlistBuddy -c "Print :desiredOSversion" "$managedPlist")
if [[ $(version $currentOS) -ge $(version $desiredOS) ]]; then
  #clean up counter file and Exit
  rm -rf "$counterFile"
  log "device is up to date, exiting....."
  /bin/cp "$logLocation" "$ws1Log"
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
if [[ "$updateType" = "major" ]]; then
  desiredProductKey="_MACOS_"$desiredOS
else
  osBuild=$(/usr/bin/plutil -p /Library/Updates/ProductMetadata.plist | /usr/bin/grep -w -B 1 "$desiredOS" | /usr/bin/awk 'NR==1{print $3}' | /usr/bin/tr -d '"')
  desiredProductKey="MSU_UPDATE_"$osBuild"_patch_"$desiredOS
fi
log "ProductKey: $desiredProductKey"


#grab API info
authToken=$(getToken $clientID $clientSec)

#check if update has downloaded, if not trigger download and exit
downloadCheck=$(dlCheck "$updateType")
if [[ "$downloadCheck" = "no" ]]; then
  dlInstaller "$updateType"
  log "installer download started, exiting....."
  /bin/cp "$logLocation" "$ws1Log"
  exit 0
fi
log "installer downloaded"

log "deferrals: $deferralCount"
log "maxDeferrals: $maxDeferrals"

#check if user is active
userStatus=$(/usr/bin/pmset -g useractivity | /usr/bin/grep "Level =" | /usr/bin/awk '{print $3}' | /usr/bin/tr -d "'")
log "User status: $userStatus"
if [[ ! "$userStatus" = "PresentActive" ]]; then
  log "user is not active so not proceeding to prompt, exiting....."
  /bin/cp "$logLocation" "$ws1Log"
  exit 0
fi

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
/bin/cp "$logLocation" "$ws1Log"
exit 0
