#!/bin/bash

#Get active interface (top actually used in service order)
active_interface=$(/sbin/route get www.apple.com | awk '/interface/ { print $2 }')
service_name=$(/usr/sbin/networksetup -listallhardwareports | grep -C 1 $active_interface | awk -F ": " '/Hardware Port/ {print $2}')
echo $service_name

# Description: Returns the name of the active network interface service name, such as Wi-Fi or Ethernet Adapter (en4) or Thunderbolt Bridge
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING