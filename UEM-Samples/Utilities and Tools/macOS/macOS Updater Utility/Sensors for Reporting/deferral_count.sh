#!/bin/zsh

###############################################################
#Sensor to check mUU Deferral count (mUU v10)
# George Gonzalez
# V 1.1
###############################################################

counterFile="/private/var/macOSupdater/mu_properties.plist"
managedPlistFile="com.macOSupdater.settings.plist"
managedPlistPath="/Library/Managed Preferences/"
managedPlist="$managedPlistPath$managedPlistFile"

if [[ ! -f "$counterFile" ]]; then

  echo "File not Found"

  exit 0

else
  deferralCount=$(/usr/libexec/PlistBuddy -c "Print deferralCount" "$counterFile")
  maxDeferrals=$(/usr/libexec/PlistBuddy -c "Print maxDeferrals" "$managedPlist")

  if [[ -z $deferralCount ]]; then

    echo "No Updates Available"

  else

    echo "$deferralCount $maxDeferrals"

  fi

fi
