#!/bin/bash
#/usr/libexec/java_home &> /dev/null && echo "installed" || echo  "not installed"
isManaged=`sudo /Library/McAfee/agent/bin/cmdagent -i | grep GUID | cut -c 7-43`

if [ $isManaged != "N/A" ] ;
then
    result="Managed"
else
    result="Unmanaged"
fi

echo $result

javainstalled=`/usr/libexec/java_home &> /dev/null`
if [ /usr/libexec/java_home ] ; then
    javaver = $(java -version) ;
    echo $javaver
else
    echo "0" ;
fi

# Description: Return Java Runtime version info
# Execution Context: SYSTEM
# Return Type: STRING