#!/bin/bash

active_interface=$(/sbin/route get www.apple.com | awk '/interface/ { print $2 }')
ifconfig $active_interface | awk '/inet6 / {print $2}'

# Description: Returns IPv6 Address of active interface.
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING