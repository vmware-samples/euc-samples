#!/bin/bash

if grep -R RegistrationId="[0-9]\{1,10\}-" "/Library/Application Support/com.vmware.carbonblack.cloud/Config/cfg.ini"; then
  echo 0
else
  echo 1
fi

# Check macOS Device Registered in Carbon Black Cloud as per https://community.carbonblack.com/t5/Knowledge-Base/Carbon-Black-Cloud-How-To-Check-DeviceID-On-Endpoint-macOS-3-5-x/ta-p/111757
# Execution Context: System
# Execution Architecture:
# Timeout: 30
# Variables: