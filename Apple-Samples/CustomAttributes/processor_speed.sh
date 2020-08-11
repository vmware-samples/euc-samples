#!/bin/bash

speed=$(/usr/sbin/sysctl machdep.cpu.brand_string | awk '{print $7}' | cut -c 1-4)
echo $speed
