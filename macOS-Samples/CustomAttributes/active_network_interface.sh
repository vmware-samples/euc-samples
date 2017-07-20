#!/bin/bash

#Get active interface (top actually used in service order)
active_interface=$(/sbin/route get www.apple.com | awk '/interface/ { print $2 }')
echo $active_interface
# en4
