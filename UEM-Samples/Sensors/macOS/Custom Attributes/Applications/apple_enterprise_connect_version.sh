#!/bin/bash
if [ -f "/Applications/Enterprise Connect.app/Contents/Info.plist" ] ; then
   /usr/bin/defaults read /Applications/Enterprise\ Connect.app/Contents/Info.plist CFBundleShortVersionString ;
else
   echo "0" ;
fi

# Description: Return Apple Enterprise Connect version info
# Execution Context: SYSTEM
# Return Type: STRING