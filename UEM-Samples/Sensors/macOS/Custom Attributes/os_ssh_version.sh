#!/bin/bash

ssh_version=$(/usr/bin/ssh -V 2>&1)

echo $ssh_version

# Description: Return SSH version
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING