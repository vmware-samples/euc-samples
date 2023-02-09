#!/bin/bash

admins=$(/usr/bin/dscl . -read /Groups/admin GroupMembership | /usr/bin/cut -c 18-)

echo $admins

# Description: Returns list of local Admin users
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING