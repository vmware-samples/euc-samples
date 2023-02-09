#!/bin/bash
if [ -f "/Applications/VMware Fusion.app/Contents/Info.plist" ] ; then
    /usr/bin/defaults read /Applications/VMware\ Fusion.app/Contents/Info.plist CFBundleShortVersionString ;
else
    echo "0" ;
fi

# Description: Return VMware Fusion version info
# Execution Context: SYSTEM
# Return Type: STRING