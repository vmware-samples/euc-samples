#!/bin/zsh
# Created by Paul Evans 5/20/2020

totalSteps=50
installPath="/Library/Application Support/macOSUpdateHelper/"
logFile=$installPath"DEPNotifyUpdateLogs.txt"
appLog=$installPath"log.txt"
plistFile="/Library/Preferences/com.vmware.macosupdatehelper.plist"
managedPrefFile="/Library/Managed Preferences/com.vmware.macosupdatehelper.plist"
outputLog=$installPath"macOSUpdateHelperLog.txt"

/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - " >> "$outputLog"
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - --------------------------------" >> "$outputLog"
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Starting up macOSUpdateHelper..." >> "$outputLog"
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - --------------------------------" >> "$outputLog"
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - " >> "$outputLog"

########## Functions ##########
startosinstallFinished()
{
	/bin/echo "Received SIGUSR1"
	currentsize=$(du -s "/macOS Install Data/" | awk '{print $1}')
	currentsize=$(( $currentsize / 2048 ))
	/bin/echo "$(date +%y.%m.%d-%H:%M:%S) - Total size of macOS Install Data folder is $currentsize MB" >> "$outputLog"
	/bin/echo "$(date +%y.%m.%d-%H:%M:%S) - macOS Update is fully downloaded.  Prompting user to restart..." >> "$outputLog"
	/bin/echo "Command: MainText: Your system will restart automatically in one minute." >> "$logFile"
	/bin/echo "Status: Download Complete" >> "$logFile"
	#/bin/echo "Command: Restart: Your system will restart automatically in one minute.  Click to close this window." >> "$logFile"
	
	/bin/sleep 120
	#exit 0
}

trap 'startosinstallFinished'  SIGUSR1

checkBatteryPower()
{
	batt=$(pmset -g batt | grep charged | awk '{print $3}')
	batt="${batt%\%*}"

	AC=$(pmset -g batt | grep AC | awk '{print $4}')
	AC="${AC##*\'}"

	if [[ $AC = "AC" || ( batt -ge 50 ) ]]; then
		/bin/echo 1
	else
		/bin/echo 0
	fi
}

version()
{ 
	/bin/echo "$@" | awk -F. '{ printf("1%03d%03d%03d\n", $1,$2,$3,$4); }'; 
} 

########## stall until user logs in ##########

uid=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = SCDynamicStoreCopyConsoleUser(None, None, None)[1]; sys.stdout.write(str(username) + "\n");')
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - currentUser is $uid" >> "$outputLog"
while [ ! $uid -gt 500 ]; do
	/bin/sleep 300
	uid=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = SCDynamicStoreCopyConsoleUser(None, None, None)[1]; sys.stdout.write(str(username) + "\n");')
	/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - currentUser is $uid" >> "$outputLog"
done


########## Handle Passed In Arguments ##########

forced=0

while /usr/bin/getopts ":f" opt; do
	case ${opt} in
    		f ) 	forced=1
			;;
		\? ) 	/bin/echo "Usage: macOSUpdate.sh [-f]"
      			;;
  	esac
done

/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Force Upgrade set to: $forced" >> "$outputLog"


########## Retrieve Managed Settings ##########

macOSVersion=$(/usr/bin/defaults read "$managedPrefFile" macOSVersion 2>/dev/null)
case $macOSVersion in
	10.15)
		expectedSize=7871
		installerPath="/Applications/Install macOS Catalina.app/Contents/Resources/startosinstall"
		/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Target macOS version is Catalina" >> "$outputLog"
		;;
	*)	
		macOSVersion="10.15"
		expectedSize=7871
		installerPath="/Applications/Install macOS Catalina.app/Contents/Resources/startosinstall"
		/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Defaulting target macOS version to Catalina" >> "$outputLog"
esac

allowUserPrep=$(/usr/bin/defaults read "$managedPrefFile" allowUserPrep 2>/dev/null)
if [[ $allowUserPrep != 0 && $allowUserPrep != 1 ]]; then
	allowUserPrep=1
fi
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - allowUserPrep is set to: $allowUserPrep" >> "$outputLog"

allowDeferrals=$(/usr/bin/defaults read "$managedPrefFile" allowDeferrals 2>/dev/null)
if [[ $allowDeferrals != 0 && $allowDeferrals != 1 ]]; then
	allowDeferrals=0
fi
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - allowUserPrep is set to: $allowUserPrep" >> "$outputLog"

numberOfDeferrals=$(/usr/bin/defaults read "$managedPrefFile" numberOfDeferrals 2>/dev/null)
if [[ $numberOfDeferrals != <-> ]]; then
	numberOfDeferrals=-1
fi
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - numberOfDeferrals is set to: $numberOfDeferrals" >> "$outputLog"

notificationInterval=$(/usr/bin/defaults read "$managedPrefFile" notificationInterval 2>/dev/null)
if [[ $notificationInterval != <-> ]]; then
	notificationInterval=28800
fi
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - notificationInterval is set to: $notificationInterval" >> "$outputLog"

goLiveDate=$(/usr/bin/defaults read "$managedPrefFile" goLiveDate 2>/dev/null)
currentDate=$(/bin/date -j +"%Y.%m.%d")
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - currentDate is: $currentDate" >> "$outputLog"
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - goLiveDate is set to: $goLiveDate" >> "$outputLog"
goLive="0"
if [[ $(version $goLiveDate) -le $(version $currentDate) ]]; then
	goLive="1"
	/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - We're doing it live!" >> "$outputLog"

fi

deferralNotificationType=$(/usr/bin/defaults read "$managedPrefFile" deferralNotificationType 2>/dev/null)
# goLiveDate | numberOfDeferrals
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - deferralNotificationType is set to: $deferralNotificationType" >> "$outputLog"

fullScreenDownloader=$(/usr/bin/defaults read "$managedPrefFile" fullScreenDownloader 2>/dev/null)
if [[ $fullScreenDownloader != 0 && $fullScreenDownloader != 1 ]]; then
	fullScreenDownloader=0
fi
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - fullScreenDownloader is set to: $fullScreenDownloader" >> "$outputLog"


updateIcon=$(/usr/bin/defaults read "$managedPrefFile" updateIcon 2>/dev/null)
if [[ $updateIcon != "1" ]]; then
	updateIcon=0
fi
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - updateIcon is set to: $updateIcon" >> "$outputLog"

iconURL=$(/usr/bin/defaults read "$managedPrefFile" iconURL 2>/dev/null)
iconExtension="${iconURL##*.}"


########## Retrieve App Preferences ##########


if [[ ! -a "$plistFile" ]]; then
	/usr/libexec/PlistBuddy -c 'Add :Version string 1.0' "$plistFile"
fi


currentDeferrals=$(/usr/bin/defaults read "$plistFile" Deferrals 2>/dev/null)
if [[ $currentDeferrals = "" ]]; then
	currentDeferrals=0
elif [[ $currentDeferrals != <->  || $currentDeferrals > $numberOfDeferrals ]]; then
	currentDeferrals=$numberOfDeferrals
fi

/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - currentDeferrals is set to: $currentDeferrals" >> "$outputLog"
/bin/echo "currentDeferrals: $currentDeferrals"

lastDeferral=$(/usr/bin/defaults read "$plistFile" lastDefferal 2>/dev/null)
if [[ $lastDeferral != <-> ]]; then
	lastDeferral=0
fi

/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - lastDeferral is set to: $lastDeferral" >> "$outputLog"

forced=$(/usr/bin/defaults read "$plistFile" force 2>/dev/null)
if [[ $forced != 1 ]]; then
	forced=0
else
	/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - User chose not to defer update." >> "$outputLog"
fi

########## Script ##########

# Make sure you're not on the target version
if [[ $(version $(sw_vers -productVersion)) -ge $(version $macOSVersion) ]]; then
	/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Device is already on macOS version $macOSVersion." >> "$outputLog"
	/bin/launchctl unload -w /Library/LaunchDaemons/com.vmware.macosupdatehelper.plist
	/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Unloaded LaunchDaemon. Exiting..." >> "$outputLog"
	/bin/sleep 5
	exit 0
fi
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Device is not yet on macOS version $macOSVersion." >> "$outputLog"

#check if user accepted notification or goLive has passed
if [[ $forced != 1 && $goLive != "1" && $allowDeferrals != "0" ]]; then

	# Wait until the apprpriate time has passed since last deferral
	targetTime=$(( $lastDeferral + $notificationInterval ))
	/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Will begin next attempt at $targetTime." >> "$outputLog"
	while [[ $targetTime -gt $(/bin/date +%s) ]]; do
		/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Too soon for next attempt.  Trying again in one minute." >> "$outputLog"
		/bin/sleep 60
	done
	/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Ready to begin next attempt." >> "$outputLog"


	if [[ $numberOfDeferrals = "-1" || ( $currentDeferrals -lt $numberOfDeferrals ) ]]; then
		newDeferrals=$(( $currentDeferrals + 1 ))
		/usr/bin/defaults write "$plistFile" Deferrals -int $(( $currentDeferrals + 1 ))
		/usr/bin/defaults write "$plistFile" lastDefferal -int $(/bin/date +%s)
		
		if [[ $deferralNotificationType = "numberOfDeferrals" ]]; then
			deferMessage="You may defer $(( $numberOfDeferrals - $currentDeferrals )) more times"
		elif [[ $deferralNotificationType = "goLiveDate" ]]; then
			deferMessage="You may defer until $goLiveDate"
		else
			deferMessage=""
		fi

		#sudo /usr/bin/defaults write /Library/Preferences/com.vmware.macosupdatehelper.plist force -bool true; sudo /bin/kill $(sudo /bin/launchctl list | grep com.vmware.macosupdatehelper | awk '{print $1}')
		#/usr/bin/defaults write /Library/Preferences/com.vmware.macosupdatehelper.plist force -bool true; /bin/kill $(/bin/launchctl list | grep com.vmware.macosupdatehelper | awk '{print $1}')
		/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Notifying user to update.  Deferral $currentDeferrals of $numberOfDeferrals..." >> "$outputLog"
		/usr/local/bin/hubcli notify --title "macOS Update" --subtitle "Click to begin macOS Update process" --info "$deferMessage" --actionbtn "Begin" --script "sudo /Library/Application\ Support/macOSUpdateHelper/force.sh" --cancelbtn "Defer"
		exit 0
	else
		/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Maximum number of deferrals exceeded.  Initiating update process..." >> "$outputLog"
	fi
else
	if [[ $forced = "1" ]]; then
		/usr/bin/defaults delete /Library/Preferences/com.vmware.macosupdatehelper.plist force
	fi
	/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Forcing update process to initiate..." >> "$outputLog"
fi

currentSize=0
currDeter=1

/usr/bin/touch "$logFile"
/bin/chmod 644 "$logFile"
/usr/bin/touch "$appLog"
/bin/chmod 644 "$appLog"

/bin/echo "My PID is $$"

if [[ $updateIcon = 1 ]]; then
	newIcon="newIcon."$iconExtension
	iconPath="$installPath""$newIcon"
	curl "$iconURL" > "$iconPath"
else
	iconPath="$installPath""WS1_icon.png"
fi

/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - iconPath is $iconPath" >> "$outputLog"

# Show user prep screen if supported and goLiveDate not passed
if [[ $allowUserPrep = "1" && $goLive != "1" ]]; then
	/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Showing prep screen to user." >> "$outputLog"
	/bin/echo "" > "$logFile"
	/bin/echo "Command: Image: ""$iconPath" >> "$logFile"
	/bin/echo "Command: MainTitle: Begin macOS Update" >> "$logFile"
	/bin/echo "Command: MainText: Select \"Begin Install\" to start downloading and installing the latest macOS update.  Make sure to save any open documents before selecting \"Being Install.\" \n \n You will not be able to use your system while the update is downloading and installing.  This full process typically takes between 1-2 hours.  Your system will automatically restart when the download is complete." >> "$logFile"
	/bin/echo "Status: " >> "$logFile"
	/bin/echo "Command: ContinueButton: Begin Install" >> "$logFile"

	"/Applications/Utilities/DEPNotify.app/Contents/MacOS/DEPNotify" -path "$logFile" > "$appLog" 2>&1 &
	DEPNotifyPID=$!
	
	while /bin/ps -p $DEPNotifyPID > /dev/null
	do
		/bin/sleep 5
	done
else
	/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Skipping prep screen." >> "$outputLog"
fi

# Begin update process
/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Beginning download of macOS update." >> "$outputLog"
/bin/echo "" > "$logFile"
/bin/echo "Command: Image: ""$iconPath" >> "$logFile"
/bin/echo "Command: MainTitle: Downloading macOS Update" >> "$logFile"
/bin/echo "Command: MainText: Your system will automatically restart when the download is complete." >> "$logFile"
/bin/echo "Status: Initializing installer.  This may take a few minutes." >> "$logFile"

"$installerPath" --agreetolicense --rebootdelay 60 --pidtosignal $$ > "$appLog" 2>&1 &
startOSInstallPID=$!

if [[ $fullScreenDownloader = "1" ]]; then
	"/Applications/Utilities/DEPNotify.app/Contents/MacOS/DEPNotify" -fullScreen -path "$logFile" > "$appLog" 2>&1 &
	DEPNotifyPID=$!
else
	"/Applications/Utilities/DEPNotify.app/Contents/MacOS/DEPNotify" -path "$logFile" > "$appLog" 2>&1 &
	DEPNotifyPID=$!
fi

echo "startOSInstallPID= $startOSInstallPID"
echo "DEPNotifyPID= $DEPNotifyPID"

downloadStarted=0
oldsize=$(( expectedSize * 2 ))

while [[ $currDeter -lt $(( $totalSteps + 1 )) ]]
do
	currentsize=$(du -s "/macOS Install Data/" | awk '{print $1}')

	if [ "$currentsize" = "" ]; then
		currentsize=0
	fi 
	currentsize=$(( $currentsize / 2048 ))

	if [ "$downloadStarted" = "0" ]; then
		if [ $currentsize -gt $oldsize ]; then
			/bin/echo "Status: 0% Downloaded" >> "$logFile"
			/bin/echo "Command: Determinate: 50" >> "$logFile"
			downloadStarted=1
		fi
	else
		while [[ $(( 100.0 * $currentsize / $expectedSize )) -ge $(( $currDeter * 100.0 / $totalSteps )) ]]
		do
			currProgress=$(( 100 * $currentsize / $expectedSize ))
			/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Download Progress: $currProgress%" >> "$outputLog"
			/bin/echo "Status: $currProgress% Downloaded" >> "$logFile"
			currDeter=$(( $currDeter + 1 ))
		done

		/bin/echo "Command: MainText: Your system will automatically restart when the download is complete. \n Downloaded: $currentsize out of $expectedSize MBs" >> "$logFile"
	fi

	oldsize=$currentsize
	/bin/sleep 5
done

/bin/echo "$(/bin/date +%y.%m.%d-%H:%M:%S) - Download complete.  Stalling until startosinstall command signals complete." >> "$outputLog"
/bin/echo "Command: MainText: Preparing install..." >> "$logFile"
/bin/echo "Status: Download Complete" >> "$logFile"

while /usr/bin/true
do
	/bin/sleep 60
done

