# Firewall Exception Tool

## Overview
- **Author**: Mike Nelson
- **Email**: miken@vmware.com
- **Date Created**: 02/26/2018
- **Tested on**: Windows 10 1709

## SYNOPSIS
This script takes an Excel spreadsheet as input and generates the necessary Firewall exceptions for each of the specified applications.

## Requirements

1. Script must be run on a machine that has Microsoft Excel instsalled.
1. Windows 10 - 1709

## Steps

1. Fill in the included spreadsheet template with the desired applications and configurations for each application.
1. Run the script by opening a powershell prompt and running ```.\FirewallAppExceptionTool.ps1```
1. When prompted select the spreadsheet that will serve as the input data.
1. The tool will run and generate two xml files.
  
    1. Copy the contents of MDMAddFirewallRules.xml into a Custom XML profile in the AirWatch Console.
    1. The MDMRemoveFirewallRules.xml file contains the necessary xml to remove the Firewall rules from a device if needed. 


        
## Resources

[Firewall CSP](https://docs.microsoft.com/en-us/windows/client-management/mdm/firewall-csp)

[Custom Profile Documentation](https://my.air-watch.com/help/9.2/en/Content/Platform_Guides/WinDesktop/T/Profile_CustomConfigWD.htm)

[Firewall Templates](https://github.com/vmwaresamples/AirWatch-samples/tree/master/Windows-Samples/Custom%20Settings/Firewall%20Rules)

## Updates

- 02/26/18 Created
