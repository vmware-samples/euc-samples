#!/bin/bash

if [ -x "/Applications/Application.app" ]; then /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString:" "/Applications/Application.app/Contents/Info.plist"; else echo "0.0"; fi

# Description: Paste the following in a macOS Custom Attributes payload to create an "App Version" attribute that can be leveraged as an "Assignment Rule" for a Product
# Modify the "/Applications/Application.app" strings to instead reference the desired app folder
# Execution Context: SYSTEM
# Return Type: STRING