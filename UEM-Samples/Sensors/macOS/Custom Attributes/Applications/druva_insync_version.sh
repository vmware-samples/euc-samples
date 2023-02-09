#!/bin/bash
if [ -f "/Applications/Druva inSync/inSync.app/Contents/Info.plist" ] ; then
    /usr/bin/defaults read /Applications/Druva\ inSync/inSync.app/Contents/Info.plist CFBundleShortVersionString ;
else
    if [ -f "/Applications/inSync.app/Contents/Info.plist" ] ; then
        /usr/bin/defaults read /Applications/inSync.app/Contents/Info.plist CFBundleShortVersionString ;
    else
        echo "0" ;
    fi
fi

# Description: Return Druva InSync version info
# Execution Context: SYSTEM
# Return Type: STRING