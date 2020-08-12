#!/bin/bash
if [ -f "/Applications/Skype for Business.app/Contents/Info.plist" ] ; then
    /usr/bin/defaults read /Applications/Skype\ for\ Business.app/Contents/Info.plist CFBundleShortVersionString ;
else
    echo "0" ;
fi
