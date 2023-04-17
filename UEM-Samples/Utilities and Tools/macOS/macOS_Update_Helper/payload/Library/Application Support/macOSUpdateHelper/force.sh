#!/bin/zsh
# Created by Paul Evans 5/20/2020

/usr/bin/defaults write /Library/Preferences/com.vmware.macosupdatehelper.plist force -bool true; /bin/kill $(/bin/launchctl list | grep com.vmware.macosupdatehelper | awk '{print $1}')