#!/bin/bash

batcondition=$(/usr/sbin/system_profiler SPPowerDataType | awk '/Condition/{$1="";print}' | cut -c 2-)
echo $batcondition

# Description: Returns current battery highlevel status
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING