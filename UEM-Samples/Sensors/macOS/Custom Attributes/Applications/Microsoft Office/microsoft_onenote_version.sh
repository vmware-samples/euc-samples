#!/bin/bash
if [ -f "/Applications/Microsoft OneNote.app/Contents/Info.plist" ] ; then
    /usr/bin/defaults read /Applications/Microsoft\ OneNote.app/Contents/Info.plist CFBundleShortVersionString ;
else
    echo "0" ;
fi
