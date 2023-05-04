#!/bin/bash

os=$(sw_vers -ProductVersion)
RSR=$(sw_vers -ProductVersionExtra &>/dev/null)
echo "$os $RSR"
