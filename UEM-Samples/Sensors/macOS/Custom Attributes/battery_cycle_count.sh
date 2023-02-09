#!/bin/bash

cyclecount=$(ioreg -n AppleSmartBattery -r | awk '/"CycleCount" = /{print $3}')
echo $cyclecount

# Description: Returns the battery cycle count
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: INTEGER