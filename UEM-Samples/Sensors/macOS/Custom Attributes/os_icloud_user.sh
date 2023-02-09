#!/bin/zsh

loggedInUser=$( echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }' )

if [ -f /Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist ]; then

    LOGGEDIN=$(/usr/libexec/PlistBuddy -c "Print ::Accounts:0:AccountID" /Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist)
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
        echo $LOGGEDIN
    else
        echo "none"
    fi

else

    echo "none"

fi

# Description: Returns the configured iCloud username of the device
# Execution Context: USER
# Execution Architecture: UNKNOWN
# Return Type: STRING