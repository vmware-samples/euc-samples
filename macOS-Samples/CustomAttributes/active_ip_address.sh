#!/bin/bash

/usr/bin/touch /tmp/ip.py
echo """#!/usr/bin/python

import subprocess

active_interface = subprocess.check_output(['/sbin/route', 'get', 'www.apple.com'])
interface = active_interface.find('interface')
adapter = active_interface[(int(interface) + 11):].splitlines()[0]

ifconfig = subprocess.check_output(['/sbin/ifconfig', str(adapter)])
inet = ifconfig.find('inet ')
ip = ifconfig[(int(inet) + 5):].split(' ')[0]

print ip""" >> /tmp/ip.py

/bin/chmod +x /tmp/ip.py

/usr/bin/python /tmp/ip.py

/bin/rm -rf /tmp/ip.py