#!/bin/bash

cyclecount=$(ioreg -r -c "AppleSmartBattery" | grep -w "CycleCount" | awk '{print $3}' | sed s/\"//g)
echo $cyclecount
