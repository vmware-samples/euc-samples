#!/bin/bash

buildv=$(/usr/bin/sw_vers -buildVersion)
echo $buildv

# Description: Returns the OS build version
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING