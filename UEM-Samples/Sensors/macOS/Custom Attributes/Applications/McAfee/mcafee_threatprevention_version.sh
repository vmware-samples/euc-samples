#!/bin/bash

FMPVersion=`cat /usr/local/McAfee/fmp/config/FMPInfo.xml | egrep "<FMPVersion>.*</FMPVersion>" |sed -e "s/<FMPVersion>\(.*\)<\/FMPVersion>/\1/"|tr -d " "|tr -d "\t"|tr -d "\n"|tr -d "\r"`
BuildNumber=`cat /usr/local/McAfee/fmp/config/FMPInfo.xml | egrep "<BuildNumber>.*</BuildNumber>" |sed -e "s/<BuildNumber>\(.*\)<\/BuildNumber>/\1/"|tr -d " "|tr -d "\t"|tr -d "\n"|tr -d "\r"`
TPVersion="$FMPVersion.$BuildNumber"
echo $TPVersion

# Description: Return McAfee Threat Prevention version info
# Execution Context: SYSTEM
# Return Type: STRING