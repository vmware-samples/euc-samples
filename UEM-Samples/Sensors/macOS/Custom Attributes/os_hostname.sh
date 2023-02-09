#!/bin/bash

host=`/usr/sbin/scutil --get LocalHostName`

echo $host
# Description: Returns hostname of device
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING