#!/bin/bash
if [ -f "/Applications/GlobalProtect.app/Contents/Info.plist" ] ; then
    /usr/bin/defaults read /Applications/GlobalProtect.app/Contents/Info.plist CFBundleShortVersionString ;
else
    echo "0" ;
fi

# Description: Return Palo Alto Global Protect version info
# Execution Context: SYSTEM
# Return Type: STRING