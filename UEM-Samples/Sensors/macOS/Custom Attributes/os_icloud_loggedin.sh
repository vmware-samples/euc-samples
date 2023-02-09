#!/bin/zsh

loggedInUser=$( echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }' )

if [ -f /Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist ]; then

    if [ $(/usr/libexec/PlistBuddy -c "Print ::Accounts:0:LoggedIn" /Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist) ]; then
        LOGGEDIN="TRUE"
    else
        LOGGEDIN="FALSE"
    fi

else

    LOGGEDIN="FALSE"

fi

echo $LOGGEDIN

# Description: Returns True or False if user is logged in
# Execution Context: USER
# Execution Architecture: UNKNOWN
# Return Type: BOOLEAN