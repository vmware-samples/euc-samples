# EUC-samples is now hosted https://github.com/euc-oss/euc-samples.
# This repo is no longer maintained.

# Apple Enterprise Connect

## Overview
- **Author**: Robert Terakedis
- **Email**: rterakedis@vmware.com
- **Date Created**: 6/8/2017
- **Supported Platforms**: AirWatch version 9.0
- **Tested on macOS Versions**: macOS El Capitan, macOS Sierra

## Purpose 
The Apple Enterprise Connect file contains an XML snippet that can be used in a Custom XML payload to customize the configuration of Apple's Enterprise Connect software.   

## Required Changes/Updates
You must replace the following items in the Custom XML before deploying it:
* adRealm:  Replace the value "YOUR.DOMAIN.REALM" with the realm of your organization (e.g. ldap.company.com)
* connectionCompletedScriptPath:  Replace with the name of any script file that should be executed.
* disableQuitMenu:  ensure the value is set correctly below this key (<true/> or <false/>)
* mountNetworkHomeDirectory:  ensure the value is set correctly below this key (<true/> or <false/>)
* syncLocalPassword:  ensure the value is set correctly below this key (<true/> or <false/>)

## Change Log
- 6/8/2017: Created Initial File


## Additional Resources
None