#!/bin/bash

os=$(sw_vers -ProductVersion)
RSR=$(sw_vers -ProductVersionExtra)
echo "$os $RSR"
