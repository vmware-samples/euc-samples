#!/bin/bash

if [ -f "/Library/Preferences/com.mcafee.ssm.StatefulFirewall.plist" ]; then
    result=`/usr/bin/defaults read /Library/Preferences/com.mcafee.ssm.StatefulFirewall IsFirewallEnabled`
fi

if [ "$result" = "1" ]; then
    echo "Enabled"
else
    echo "Disabled"
fi

# Description: Return Enabled or Disabled for McAfee Firewall Status
# Execution Context: SYSTEM
# Return Type: STRING