#!/bin/bash

chipversion=$(/usr/sbin/system_profiler SPiBridgeDataType | awk '/Model/ {print $4}')

if [ -z "$chipversion" ]
then
	echo "Pre T1"
else
	echo $chipversion
fi

# Description: Return the T-Series chip value, if present. If a pre T-series device, will report "Pre T1"
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING