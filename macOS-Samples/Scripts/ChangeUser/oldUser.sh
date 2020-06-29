#!/bin/bash

# REST API FQDN
uemAPI="as000.awmdm.com"
 
# Authorization
uemAuth="XXXXXXXXXXXXXXXXXXXX"
 
# Tenant code
uemCode="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX="

# Change user working path
workingPath="/Library/VMware/WS1/changeUser"

# Create working path
mkdir -p $workingPath 

# Log file name
logFile="$workingPath/changeUser.log"

# Old user file name
oldUserFile="$workingPath/changeUser.old"

# New user file name
newUserFile="$workingPath/changeUser.new"

# Current date/time
dateCurrent=$(date '+%Y-%m-%d %I:%M:%S')

# Create log event
logEvent="[${dateCurrent}] [oldUser]"

# Create the log file
touch $logFile

# Open permissions to account for all error catching
chmod 666 $logFile

# Begin Logging
echo "${logEvent} Initializing script" >> $logFile

# Get current console user
currentUser=`ls -l /dev/console | awk {' print $3 '}`

# Begin Logging
echo "${logEvent} Current user: $currentUser" >> $logFile

# Create old user file
touch $oldUserFile

# Write old user file
echo $currentUser > $oldUserFile

# Log old user file
echo "${logEvent} Creating old user file: $oldUserFile" >> $logFile

macSerial=`ioreg -l | grep IOPlatformSerialNumber | awk '{print $4}' | sed "s/\"//g"`

declare -a curlHeaders2=('-H' "Content-Type: application/json" '-H' "Accept: application/json;version=2" '-H' "Authorization: Basic $uemAuth" '-H' "aw-tenant-code: $uemCode")

devIdLong=`curl -s -X GET "${curlHeaders2[@]}" "https://$uemAPI/API/mdm/devices/?searchBy=Serialnumber&id=$macSerial"`
devId=`echo ${devIdLong: -54: 6}`
uemUser=`curl -s -X GET "${curlHeaders2[@]}" "https://$uemAPI/API/mdm/devices/$devId/user"`
uemUser1=`echo $uemUser | awk -F',' '{print $1}'`
uemUser2=`echo $uemUser1 | awk -F':' '{print $3}'`
uemUser3=`echo $uemUser2 | tr -d '"'`

# Create new user file
touch $newUserFile

# Write new user file
echo $uemUser3 > $newUserFile

# Log new user file
echo "${logEvent} Creating new user file: $newUserFile" >> $logFile

# Return Custom Attributes value
echo $currentUser
