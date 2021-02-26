#!/bin/zsh

PROC=$(/usr/sbin/s  ysctl -n machdep.cpu.brand_string)

if grep -q "Apple" <<< "$PROC"; then
	echo "arm64"
else
	if grep -q "Intel" <<< "$PROC"; then
    	echo "x86_x64"
    else
    	echo "unknown_cpu"
    fi
fi
