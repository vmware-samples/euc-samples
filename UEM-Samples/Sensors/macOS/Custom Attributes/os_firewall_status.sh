#!/bin/bash

status=$(/usr/bin/defaults read /Library/Preferences/com.apple.alf globalstate)

if [ "$status" = "1"]; then
    echo "Enabled";
else
    echo "Disabled";
fi

# Description: Returns Apple firewall enabled / disabled status
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING