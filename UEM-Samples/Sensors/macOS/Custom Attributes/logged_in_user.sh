#!/bin/bash

loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = SCDynamicStoreCopyConsoleUser(None, None, None)[0]; sys.stdout.write(username + "\n");'`
echo $loggedInUser
