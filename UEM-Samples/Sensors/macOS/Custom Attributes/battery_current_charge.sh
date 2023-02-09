#!/bin/bash

currentcharge=$(pmset -g batt | awk '/charging|discharging|charged/ {print $3}' | cut -d";" -f1)
echo $currentcharge

# Description: Returns current battery charge percentage
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING