#!/bin/bash
if [ -f "/Applications/SecurID.app/Contents/Info.plist" ] ; then
    /usr/bin/defaults read /Applications/SecurID.app/Contents/Info.plist CFBundleShortVersionString ;
else
    echo "0" ;
fi

# Description: Return RSA SecureID version info
# Execution Context: SYSTEM
# Return Type: STRING