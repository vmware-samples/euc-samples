#!/bin/bash

lastreboot=$(/usr/bin/last reboot | head -n1 | cut -d ' ' -f30-)
echo $lastreboot

#Tue Sep 27 15:04
#Can be formatted differently or to an integer

#also try `uptime`
