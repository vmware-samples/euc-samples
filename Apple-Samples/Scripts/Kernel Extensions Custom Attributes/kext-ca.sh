#!/bin/bash
# v0.5

# PURPOSE:
# Per macOS 10.13.2, 3rd-Party kernel extensions must be whitelisted by MDM or they must be User-Approved.
# This script helps admins discover 3rd-Party (non-Apple) kernel extensions and adds them as Custom Attribute Keys locally (with null value)
# This script should be deployed as a PRODUCT, and NOT as a Custom Attribute Profile Payload.
# You an export the list of Custom Attributes/Kexts via Devices > Staging & Provisioning > Custom Attributes > List View 
# The Custom Attributes are saved to the console as <Team ID>---<Bundle ID>    (You should be able to find/replace the 3 hyphens to alter the exported csv)
# Based on Findings from Richard Purves - http://www.richard-purves.com/2017/11/12/kextpocalyse-2-the-remediation/


# start logging
/usr/bin/logger -is -t AirWatch "[KEXT-CustomAttributes] script started..." 2>/dev/null

# Start Searching for KEXTs in the usual locations
/usr/bin/logger -is -t AirWatch "[KEXT-CustomAttributes] Searching Applications folder" 2>/dev/null
kexts=($(/usr/bin/find /Applications -name "*.kext" 2>/dev/null))

/usr/bin/logger -is -t AirWatch "[KEXT-CustomAttributes] Searching Extensions folder" 2>/dev/null
kexts+=($(/usr/bin/find /Library/Extensions -name "*.kext" -maxdepth 1 2>/dev/null) )

/usr/bin/logger -is -t AirWatch "[KEXT-CustomAttributes] Searching App Support folder" 2>/dev/null
kexts+=("$(/usr/bin/find /Library/Application\ Support -name "*.kext" 2>/dev/null)")


#Check each Kernel Extension to see if it's in the Custom Attributes plist
for (( i=0; i<${#kexts[@]}; i++ ))
do
    /usr/bin/logger -is -t AirWatch "[KEXT-CustomAttributes] Working ${kexts[$i]}" 2>/dev/null
	
	# Get Kext Team ID by filtering stderr output for the Developer ID Application
	tid=$(/usr/bin/codesign -d -vvv "${kexts[$i]}" 2>&1 | grep "Developer ID Application:" | awk '{print $NF}' | sed 's/[)(]//g')
	team=$(/usr/bin/codesign -d -vvv "${kexts[$i]}" 2>&1 | grep "Developer ID Application:")
	team=${team##*:}
	/usr/bin/logger -is -t AirWatch "[KEXT-CustomAttributes] Team ID: $tid" 2>/dev/null
	
	# Get Kext Bundle ID by filtering stderr output 
	bid=$(/usr/bin/codesign -d -vvv "${kexts[$i]}" 2>&1 | grep "Identifier=com.")
	bid=${bid##*=}
	/usr/bin/logger -is -t AirWatch "[KEXT-CustomAttributes] Bundle ID: $bid" 2>/dev/null

	#Smoosh the results for reporting as a Custom Attribute
	keyname=$tid---$bid
	/usr/bin/logger -is -t AirWatch "[KEXT-CustomAttributes] script found $keyname" 2>/dev/null
	
	#check to see if kext attribute exists already or not
	ca=($(/usr/libexec/PlistBuddy -c "Print :$keyname" /Library/Application\ Support/AirWatch/Data/CustomAttributes/CustomAttributes.plist 2>/dev/null))
	
	#check if result is empty
	if [ -z "$ca" ]
	then
		#ca is empty, so add custom attribute
		/usr/bin/logger -is -t AirWatch  "[KEXT-CustomAttributes] Adding Custom Attribute $keyname" 2>/dev/null
		sudo /usr/libexec/PlistBuddy -c "Add :$keyname String $team" /Library/Application\ Support/Airwatch/Data/CustomAttributes/CustomAttributes.plist 2>/dev/null
	else
		#ca has a value, skip
		/usr/bin/logger -is -t AirWatch "[KEXT-CustomAttributes] Custom Attribute $keyname already found" 2>/dev/null
	fi
done

