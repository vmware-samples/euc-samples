#!/bin/bash
if [ -f "//Applications/Socialcast.app/Contents/Info.plist" ] ; then
    /usr/bin/defaults read /Applications/Socialcast.app/Contents/Info.plist CFBundleShortVersionString ;
else
    echo "0" ;
fi
