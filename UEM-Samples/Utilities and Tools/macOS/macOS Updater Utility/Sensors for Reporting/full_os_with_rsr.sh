#!/bin/bash

os=$(sw_vers -ProductVersion)
rsr=$(sw_vers -ProductVersionExtra)
if [[ "$rsr" == "Usage"* ]]; then
	rsr=""
fi
echo "$os $rsr"
