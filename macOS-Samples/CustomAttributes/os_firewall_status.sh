#!/bin/bash

status=$(/usr/bin/defaults read /Library/Preferences/com.apple.alf globalstate)

if [ "$status" = "1"]; then
    echo "Enabled";
else
    echo "Disabled";
fi
