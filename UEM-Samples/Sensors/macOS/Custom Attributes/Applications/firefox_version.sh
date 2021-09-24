#!/bin/bash
if [ -f "//Applications/Firefox.app/Contents/Info.plist" ] ; then
    /usr/bin/defaults read /Applications/Firefox.app/Contents/Info.plist CFBundleShortVersionString ;
else
    echo "0" ;
fi
