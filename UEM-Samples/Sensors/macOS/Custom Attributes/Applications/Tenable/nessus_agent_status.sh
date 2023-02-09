#!/bin/bash

ns=$(/usr/bin/python -c "import subprocess; nessus_status = subprocess.check_output(['/Library/NessusAgent/run/sbin/nessuscli', 'agent', 'status']).replace(':', ' ').split('\n'); print nessus_status[0] + ' ' + nessus_status[1]")

echo $ns

# Description: Return Tenable Nessus Agent status info
# Execution Context: SYSTEM
# Return Type: STRING