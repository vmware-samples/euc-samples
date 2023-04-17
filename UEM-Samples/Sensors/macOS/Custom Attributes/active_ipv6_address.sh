#!/bin/bash

/Library/Application\ Support/AirWatch/Data/Munki/bin/Python.framework/Versions/3.10/bin/python3 <<- "EOF"

import subprocess
active_interface = subprocess.check_output(['/sbin/route', 'get', 'www.apple.com']).decode('utf8')
interface = active_interface.find('interface')
adapter = active_interface[(int(interface) + 11):].splitlines()[0]

ifconfig = subprocess.check_output(['/sbin/ifconfig', str(adapter)]).decode('utf8')
inet6 = ifconfig.find('inet6 ')
ipv6 = ifconfig[(int(inet6) + 6):].split(' ')[0]

print(ipv6)
EOF

