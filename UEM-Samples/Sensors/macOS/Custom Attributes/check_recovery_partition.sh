#!/bin/bash

recoveryHDPresent=$(/usr/sbin/diskutil list | grep "Apple_Boot" | awk '{print $2}')
if [ "$recoveryHDPresent" = "" ]; then
   echo "false"
else
   echo "true"
fi

# Description: Return true or false if recovery partition is enabled
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: BOOLEAN