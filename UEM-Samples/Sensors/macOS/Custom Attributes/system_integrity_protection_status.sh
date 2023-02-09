#!/bin/bash

SIP_status=$(/usr/bin/csrutil status | awk '/status/ {print $5}' | sed 's/\.//')
if [ $SIP_status = "enabled" ]; then
   echo "Enabled"
elif [ $SIP_status = "disabled" }; then
   echo "Disabled"

# Description: Check if SIP (system integrity protection) is enabled
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING