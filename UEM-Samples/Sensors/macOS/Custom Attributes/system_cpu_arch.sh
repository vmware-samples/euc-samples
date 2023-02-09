#!/bin/zsh

PROC=$(/usr/sbin/sysctl -n machdep.cpu.brand_string)

if grep -q "Apple" <<< "$PROC"; then
	echo "arm64"
else
	if grep -q "Intel" <<< "$PROC"; then
    	echo "x86_x64"
    else
    	echo "unknown_cpu"
    fi
fi

# Description: Returns CPU processor architecture. Either arm64, x86_64 or unknown_cpu.
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING