#!/bin/bash
if [ -f "/Applications/Microsoft Excel.app/Contents/Info.plist" ] ; then
    /usr/bin/defaults read /Applications/Microsoft\ Excel.app/Contents/Info.plist CFBundleShortVersionString ;
else
    echo "0" ;
fi

# Description: Return Microsoft Excel version info
# Execution Context: SYSTEM
# Return Type: STRING