#!/bin/sh

#variables
hostname=$(hostname)
computername=$(scutil --get ComputerName)
localhostname=$(scutil --get LocalHostName)

mac_name="APL"$SN
desktopname="${desktopname//:}"

if [ "$hostname" != "$mac_name" ]; then
    /usr/sbin/scutil --set HostName "$laptopname"
fi

if [ "$localhostname" != "$mac_name" ]; then
    /usr/sbin/scutil --set LocalHostName "$laptopname"
fi

if [ "$computername" != "$mac_name" ]; then
    /usr/sbin/scutil --set ComputerName "$laptopname"
fi

hostname=$(hostname)

echo $hostname


# Description: Returns current hostname of the machine
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING
# Variables: Optional
#     - Above is an example of using Serial Number as part of mac name, but you can use any variable you want.
#     - just have to make sure your variable from variable tab matches what you have in script section.
