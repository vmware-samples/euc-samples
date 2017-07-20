#!/bin/bash

datver=`/usr/bin/defaults read /Library/Preferences/com.mcafee.ssm.antimalware.plist Update_DATVersion | cut -b 1-4`
echo $datver
