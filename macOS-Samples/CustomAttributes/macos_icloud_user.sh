#!/bin/zsh
loggedInUser=$( echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }' )
LOGGEDIN=$(/usr/libexec/PlistBuddy -c "Print ::Accounts:0:AccountID" /Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist)
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo $LOGGEDIN
else
    echo "none"
fi
