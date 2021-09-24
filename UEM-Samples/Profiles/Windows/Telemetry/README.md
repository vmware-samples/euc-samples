# PRODUCTIZED #

----------

# Telemetry CSP

## Overview
- **Author**: Mike Nelson
- **Email**: miken@vmware.com
- **Date Created**: 2/1/2018
- **Supported Platforms**: Windows 10 Pro, Enterprise and Education
- **Tested on Windows 10**: 1709

## Purpose 
The [Telemetry CSP](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-system#system-allowtelemetry) is used to set the level of telemetry data sent. 

## Details
The [Telemetry CSP ](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-system#system-allowtelemetry) allows customers to set the level of telemetry data sent.

For Windows 10 the following values are valid:

* 0 for Security
* 1 for Basic
* 2 for Enhanced
* 3 for Full

Additional information regarding the levels is available via the CSP documentation.

## Usage
Replace the text in the Add-TelemetrySettings.xml sample between the data tags ```<data></data>``` with the targeted configuration level, e.g. ```<data>1</data>```

The Remove-TelemetrySettings.xml sample is used to remove the settings from a device.

## Change Log
- 2/1/2018: Created Sample for Telemetry CSP

## Additional Resources
* [Windows 10 Configuration Service Provider Reference](http://aka.ms/CSPList)
* [Telemetry Reference](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-system#system-allowtelemetry)
