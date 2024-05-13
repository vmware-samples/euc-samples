# EUC-samples is now hosted https://github.com/euc-oss/euc-samples.
# This repo is no longer maintained.

# Apply GPO to Disable writes to removable drives

## Overview
- **Author**: Arun Giridharan
- **Email**: agiridharan@vmware.com
- **Date Created**: 7/12/2017
- **Supported Platforms**: Windows 10 Desktop
- **Tested on Windows 10**: 1507, 1511, 1607, 1703

## Purpose 
This script disables writes to removable drives on a Windows 10 Desktop.

## Required Changes/Updates
You can add other GPO policy values for Volume Encryption by looking up the registry path below.
$registryPath = "HKLM:\System\CurrentControlSet\Policies\Microsoft\FVE"

## Additional Resources
* Create a product and assign to devices using the [online help instructions].(https://my.air-watch.com/help/9.1/en/Content/Platform_Guides/Rugged/_C/Products_Overview.htm)here.