#!/bin/bash
### Use this script to do any pre-vendor-removal work, such as running specific tear-down procedures ###
### This script runs after DEPNotify is opened, but before prior management is removed ###

DEPNOTIFYLOG="/private/var/tmp/depnotify.log"

echo "Status: Running Pre-Migration script" >> $DEPNOTIFYLOG

exit 0
