#!/bin/bash
if [ -f "/Applications/Skype for Business.app/Contents/Info.plist" ] ; then
    /usr/bin/defaults read /Applications/Skype\ for\ Business.app/Contents/Info.plist CFBundleShortVersionString ;
else
    echo "0" ;
fi

# Description: Return Skype for Business version info
# Execution Context: SYSTEM
# Return Type: STRING