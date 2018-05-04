#!/bin/bash
if [ -f "/var/db/FileVaultPRK.dat" ] ; then
   echo "Present"
else
   echo "Not Present" ;
fi
