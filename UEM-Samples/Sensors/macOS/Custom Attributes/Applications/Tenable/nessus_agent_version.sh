#!/bin/bash

nessus_version=$(/Library/NessusAgent/run/sbin/nessuscli --version | grep nessuscli)

echo $nessus_version

# Description: Return Tenable Nessus Agent info version info
# Execution Context: SYSTEM
# Return Type: STRING