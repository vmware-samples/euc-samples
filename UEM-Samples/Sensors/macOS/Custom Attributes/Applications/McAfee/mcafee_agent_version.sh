#!/bin/bash

version=`cat /etc/cma.d/EPOAGENT3700MACX/config.xml | egrep "<Version>.*</Version>" |sed -e "s/<Version>\(.*\)<\/Version>/\1/"|tr -d " "`
echo $version

# Description: Return McAfee Virus Scan Agent version info
# Execution Context: SYSTEM
# Return Type: STRING