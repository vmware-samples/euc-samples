# PRODUCTIZED in Workspace ONE UEM 1904 #

----------

# Firewall Samples

## Overview
- **Author**: Mike Nelson & Brooks Peppin
- **Email**: miken@vmware.com
- **Date Created**: 11/14/2017
- **Supported Platforms**: Windows 10 Desktop 1709 and above 
- **Supported SKUs**: Pro, Business, Enterprise, Education
- **Tested on**: Windows 10 1709 Enterprise

## Purpose 
This folder has a sample configurations that will apply a firewall profile or custom firewall rules for an application or service on a Windows 10 Desktop for versions 1709 and above.
The [Firewall CSP](https://docs.microsoft.com/en-us/windows/client-management/mdm/firewall-csp) was introduced in the 1709 update and only applies to the Windows 10 Desktop SKU.

The Sample configuration creates a Firewall rule that allows an applications traffic to come inbound through the firewall. Outbound rules can be specified as well.

## Required Changes/Updates
Please update the `<Data> </Data>` tag with the right values for your firewall rule and application. Please see the CSP link provided for additional nodes and configurations.

Change the Rule name route node to match each value node. Change `<CHANGEME - CustomFirewallRule Name>` to `RuleNameExample` at each LocURI in the sample.

## Change Log
- 04/04/2018: Sample for ICMP added.
- 11/14/2017: Created sample for Firewall Rules with app exceptions.

## Additional Resources
* [Windows 10 Configuration Service Provider Reference](http://aka.ms/CSPList)
* [Firewall CSP Reference](https://docs.microsoft.com/en-us/windows/client-management/mdm/firewall-csp)
