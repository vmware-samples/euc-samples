# Network Proxy Samples

## Overview
- **Author**: Varun Murthy
- **Email**: vmurthy@vmware.com
- **Date Created**: 6/25/2017
- **Supported Platforms**: Windows 10 Desktop 1703 and above
- **Tested on Windows 10**: 1703

## Purpose 
This folder has a sample configuration that will apply a machine wide network proxy on a Windows 10 Desktop for versions 1703 (Creators update) and above using an Auto-config PAC Script URL.
The [NetworkProxy CSP](https://docs.microsoft.com/en-us/windows/client-management/mdm/networkproxy-csp) was introduced in the Creator's update and only applies to the Windows 10 Desktop SKU.

## Required Changes/Updates
Please update the `<Data> </Data>` tag with the right values for your Proxy Server if using an auto-configuration. To change this to a per user setting, update the data node for the ProxySettingsPerUser node to 1. For a manually specified URL configurations please see the CSP link provided.

## Change Log
- 6/25/2017: Created sample for Setup Script (PAC) based Network Proxy sample.

## Additional Resources
* [Windows 10 Configuration Service Provider Reference](http://aka.ms/CSPList)
* [NetworkProxy CSP Reference](https://docs.microsoft.com/en-us/windows/client-management/mdm/networkproxy-csp)