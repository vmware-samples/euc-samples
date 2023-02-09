#!/bin/bash

# Use "Date Time" as the data type for the sensor. 
lastreboot=$(date -jf "%s" "$(sysctl kern.boottime | awk -F'[= |,]' '{print $6}')" +"%Y-%m-%dT%TZ")
echo "${lastreboot}"

# Description: Returns date and time of last reboot. Can be formatted differently or to an integer. Also try `uptime`
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING