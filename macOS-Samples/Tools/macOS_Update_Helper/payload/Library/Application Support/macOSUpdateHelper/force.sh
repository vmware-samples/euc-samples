#!/bin/zsh
/usr/bin/defaults write /Library/Preferences/com.vmware.macosupdatehelper.plist force -bool true; /bin/kill $(/bin/launchctl list | grep com.vmware.macosupdatehelper | awk '{print $1}')