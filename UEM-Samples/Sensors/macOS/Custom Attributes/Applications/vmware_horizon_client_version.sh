#!/bin/bash
if [ -f "/Applications/VMware Horizon Client.app/Contents/Info.plist" ] ; then
    /usr/bin/defaults read /Applications/VMware\ Horizon\ Client.app/Contents/Info.plist CFBundleShortVersionString ;
else
    echo "0" ;
fi

# Description: Return VMware Horizon Client version info
# Execution Context: SYSTEM
# Return Type: STRING