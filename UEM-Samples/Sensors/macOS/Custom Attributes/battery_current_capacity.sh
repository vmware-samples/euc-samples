#!/bin/bash

CurrentCapacity=$(ioreg -n AppleSmartBattery -r | awk '/CurrentCapacity/{print $NF}')
echo $CurrentCapacity
