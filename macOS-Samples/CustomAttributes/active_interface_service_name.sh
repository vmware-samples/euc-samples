#!/bin/bash

#Get active interface (top actually used in service order)
active_interface=$(/sbin/route get www.apple.com | awk '/interface/ { print $2 }')
service_name=$(/usr/sbin/networksetup -listallhardwareports | grep -C 1 $active_interface | awk -F ": " '/Hardware Port/ {print $2}')
echo $service_name
# Apple USB Ethernet Adapter
