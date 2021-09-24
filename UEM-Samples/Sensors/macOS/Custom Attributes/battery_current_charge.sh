#!/bin/bash

currentcharge=$(pmset -g batt | awk '/charging|discharging|charged/ {print $3}' | cut -d";" -f1)
echo $currentcharge
