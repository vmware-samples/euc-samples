#!/bin/bash

if [ -f "/Library/Preferences/com.mcafee.ssm.antimalware.plist" ]; then
    result=`date -r "$(/usr/bin/defaults read /Library/Preferences/com.mcafee.ssm.antimalware Update_Last_Update_Time)" "+%Y-%m-%d %H:%M:%S"`
    echo $result
else
    echo "Not installed"
fi
