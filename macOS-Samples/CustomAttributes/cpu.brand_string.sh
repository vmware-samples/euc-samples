#!/bin/bash
# Author Adam Matthews
# Date 7th Aug 2020
#
# Custom Attribute script to return the "Brand String" from machdep.cpu. 
# Example output: i7-7820HQ
# Name: CPU Name
#

brand_string=$(sysctl -a | grep machdep.cpu | grep machdep.cpu.brand_string | awk '/machdep/ {print $4}')

if [ -z "$brand_string" ]
then
	echo "Not Reported"
else
	echo $brand_string
fi