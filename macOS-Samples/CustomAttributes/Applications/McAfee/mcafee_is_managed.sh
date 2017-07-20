#!/bin/bash

isManaged=`sudo /Library/McAfee/agent/bin/cmdagent -i | grep GUID | cut -c 7-43`

if [ $isManaged != "N/A" ] ;
then
    result="Managed"
else
    result="Unmanaged"
fi

echo $result
