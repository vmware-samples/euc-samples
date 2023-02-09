#!/bin/bash
if [ -f "/var/db/FileVaultPRK.dat" ] ; then
   echo "Present"
else
   echo "Not Present" ;
fi

# Description: Returns Present or Not Present for File Vault existence
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING