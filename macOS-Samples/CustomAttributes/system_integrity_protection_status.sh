#!/bin/bash

#check if SIP (system integrity protection) is enabled
SIP_status=$(/usr/bin/csrutil status | awk '/status/ {print $5}' | sed 's/\.//')
if [ $SIP_status = "enabled" ]; then
   echo "Enabled"
elif [ $SIP_status = "disabled" }; then
   echo "Disabled"
