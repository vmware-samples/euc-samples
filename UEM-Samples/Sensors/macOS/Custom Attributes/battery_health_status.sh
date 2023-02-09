#!/bin/bash

result=$(ioreg -n AppleSmartBattery -r | awk '/"PermanentFailureStatus" = /{print $3}')
if [ "$result" == "1" ]; then
  result="TRUE"
elif [ "$result" == "0" ]; then
  result="FALSE"
fi
echo $result

# Description: Returns true or false of Battery PrematureFailureStatus
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: BOOLEAN