#!/bin/bash

if grep -R RegistrationId="[0-9]\{1,10\}-" /Applications/Confer.app/cfg.ini; then
  echo 0
else
  echo 1
fi

# Check macOS Device Checkin in Carbon Black Cloud
# Execution Context: System
# Execution Architecture:
# Timeout: 30
# Variables: