#!/bin/bash

recoveryHDPresent=$(/usr/sbin/diskutil list | grep "Apple_Boot" | awk '{print $2}')
if [ "$recoveryHDPresent" = "" ]; then
    echo "FALSE"
else
    echo "TRUE"
fi