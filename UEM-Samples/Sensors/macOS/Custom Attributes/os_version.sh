#!/bin/bash

osvers=$(/usr/bin/sw_vers | awk '/ProductVersion/{print $2}')
echo $osvers

# Description: Returns OS Version number
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: INTEGER