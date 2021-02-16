#!/bin/zsh
loggedInUser=$( echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }' )
ARRVAL=0
until false; do
	SERVICE=$(/usr/libexec/PlistBuddy -c "Print ::Accounts:0::Services:$ARRVAL:Name" /Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist)
    if [ "$SERVICE" = 'FIND_MY_MAC' ]; then
    	if [ $(/usr/libexec/PlistBuddy -c "Print ::Accounts:0::Services:$ARRVAL:Enabled" /Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist) ]; then
        	ENABLED="Enabled"
        else
        	ENABLED="Disabled"
  		fi
        break
  	else
    	ARRVAL="$(($ARRVAL+1))"
    fi
done
echo $ENABLED