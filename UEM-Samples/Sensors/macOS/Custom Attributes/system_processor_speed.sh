#!/bin/bash

cpuinfo=$(/usr/sbin/sysctl machdep.cpu.brand_string | awk '{print $7}' | cut -c 1-4)
echo $cpuinfo

# Description: Returns CPU info, including speed on pre M1 Models
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING