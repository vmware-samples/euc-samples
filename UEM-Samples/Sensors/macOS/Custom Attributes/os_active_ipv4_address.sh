#!/bin/bash

active_interface=$(/sbin/route get www.apple.com | awk '/interface/ { print $2 }')
ifconfig $active_interface | awk '/inet / {print $2}'

# Description: Returns IPv4 Address of active interface.
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING