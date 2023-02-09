#!/bin/bash

CurrentCapacity=$(ioreg -n AppleSmartBattery -r | awk '/"CurrentCapacity" = /{print $3}')
echo $CurrentCapacity

# Description: Returns current battery capacity
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: INTEGER