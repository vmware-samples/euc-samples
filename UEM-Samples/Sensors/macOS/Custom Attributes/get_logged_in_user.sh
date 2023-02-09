#!/bin/zsh

loggedInUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
echo $loggedInUser

# Description: Returns the username of the logged in user
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING