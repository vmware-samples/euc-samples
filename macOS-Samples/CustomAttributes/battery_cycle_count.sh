#!/bin/bash

cyclecount=$(system_profiler SPPowerDataType | grep "Cycle Count" | awk '{print $3}')
echo $cyclecount
