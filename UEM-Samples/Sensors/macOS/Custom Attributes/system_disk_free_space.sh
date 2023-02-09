#!/bin/bash

free_space=$(/usr/sbin/diskutil info /| grep 'Available Space:\|Free Space' | awk '{print $4, $5}')
echo $free_space

# Description: Returns free disk space of root volume '/'
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING