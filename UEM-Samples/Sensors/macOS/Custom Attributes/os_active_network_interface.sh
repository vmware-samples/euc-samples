#!/bin/bash

#Get active interface (top actually used in service order)
active_interface=$(/sbin/route get www.apple.com | awk '/interface/ { print $2 }')
echo $active_interface

# Description: Returns the name of the active network interface, such as en0
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING