#!/bin/bash
# Author Paul Evans / Adam Matthews
# Date 12th Feb 2020
#
# Custom Attribute script to return the T-Series chip value, if present. If a pre T-series device, will report "Pre T1".
#

chipversion=$(/usr/sbin/system_profiler SPiBridgeDataType | awk '/Model/ {print $4}')

if [ -z "$chipversion" ]
then
	echo "Pre T1"
else
	echo $chipversion
fi
