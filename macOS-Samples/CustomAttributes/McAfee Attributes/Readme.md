# McAfee-Information

## Overview
- **Author**: Robert Terakedis
- **Email**: rterakedis@vmware.com
- **Date Created**: 6/8/2017
- **Supported Platforms**: AirWatch version 9.0
- **Tested on macOS Versions**: macOS El Capitan, macOS Sierra

## Purpose 
The McAfee Information file contains command lines or scripts that can be used in a Custom Attribute payload to report various McAfee Endpoint Security/Protection for Mac attributes.   The text file contains multiple payloads - be sure to include only a single "snippet" (without the header) in the contents of your profile.

Included snippets:
* McAfee-IsManaged
* McAfee-AgentVersion
* McAfee-AntimalwareVersion
* McAfee-DatVersion
* McAfee-FirewallStatus
* McAfee-LastUpdateTime
* McAfee-OASStatus
* McAfee-AMHotfixVersion
* McAfee-ThreatPreventionVersion

## Required Changes/Updates
None

## Change Log
- 6/8/2017: Created Initial File


## Additional Resources
- Adapted from https://github.com/tziegmann/mcafee-jamf-extension-attributes