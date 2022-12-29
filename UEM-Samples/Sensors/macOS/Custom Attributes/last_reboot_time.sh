#!/bin/bash

# Use "Date Time" as the data type for the sensor. 
lastreboot=$(date -jf "%s" "$(sysctl kern.boottime | awk -F'[= |,]' '{print $6}')" +"%Y-%m-%dT%TZ")
echo "${lastreboot}"
