#!/bin/bash

currentUser=$(stat -f%Su /dev/console)
ACEplist="/Users/$currentUser/Library/Application Support/com.apple.NewDeviceOutreach/Warranty.plist"
if [ -f "$ACEplist" ];  then
  endDate=$(/usr/libexec/PlistBuddy -c "Print :coverageEndDate" "$ACEplist")
  date=$(date -j -f %s $endDate +%F)
  echo "$date"
else
  echo "Not Found"
fi

# Description: Returns Apple Care Support End Date
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING