#!/bin/bash
if [ -f "/Applications/Google Chrome.app/Contents/Info.plist" ] ; then
    /usr/bin/defaults read /Applications/Google\ Chrome.app/Contents/Info.plist CFBundleShortVersionString ;
else
    echo "0" ;
fi

# Description: Return Google Chrome browser version info
# Execution Context: SYSTEM
# Return Type: STRING