#!/bin/bash
if [ -f "/Applications/Microsoft Outlook.app/Contents/Info.plist" ] ; then
    /usr/bin/defaults read /Applications/Microsoft\ Outlook.app/Contents/Info.plist CFBundleShortVersionString ;
else
    echo "0" ;
fi

# Description: Return Microsoft Outlook version info
# Execution Context: SYSTEM
# Return Type: STRING