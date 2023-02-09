#!/bin/bash

lastreboot=$(/usr/bin/last reboot | head -n1 | cut -d ' ' -f30-)
echo $lastreboot

# Description: Returns date and time of last reboot. Can be formatted differently or to an integer. Also try `uptime`
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING