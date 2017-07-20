#!/bin/bash

batcondition=$(/usr/sbin/system_profiler SPPowerDataType | awk '/Condition/{$1="";print}' | cut -c 2-)
echo $batcondition
