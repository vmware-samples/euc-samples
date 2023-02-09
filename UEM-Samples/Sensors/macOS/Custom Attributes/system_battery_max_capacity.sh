#!/bin/bash

maxbattery=$(ioreg -n AppleSmartBattery -r | awk '/"MaxCapacity" = /{print $3}')
echo $maxbattery

# Description: Returns current battery maximum capacity percentage
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: INTEGER