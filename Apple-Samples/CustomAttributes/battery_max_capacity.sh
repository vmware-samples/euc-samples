#!/bin/bash

maxbattery=$(ioreg -n AppleSmartBattery -r | awk '/MaxCapacity/{print $NF}')
echo $maxbattery
