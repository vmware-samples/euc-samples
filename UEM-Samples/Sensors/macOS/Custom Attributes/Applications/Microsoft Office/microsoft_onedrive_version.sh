#!/bin/bash
if [ -f "/Applications/OneDrive.app/Contents/Info.plist" ] ; then
    /usr/bin/defaults read /Applications/OneDrive.app/Contents/Info.plist CFBundleShortVersionString ;
else
    echo "0" ;
fi

# Description: Return Microsoft OneDrive version info
# Execution Context: SYSTEM
# Return Type: STRING