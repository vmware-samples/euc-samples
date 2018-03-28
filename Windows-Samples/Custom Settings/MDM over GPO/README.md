# MDM over GPO

## Overview
- **Author**: Ameya Jambavalikar
- **Email**: ajambavalikar@vmware.com
- **Date Created**: 03/26/2018
- **Tested on**: Windows 10 Enterprise 1803

        
## Description
This policy allows IT admins to control which policy will be used when both MDM policy and the equivalent Group Policy are set on the device.

## Background
This policy is used to ensure that MDM policy wins over GP when same setting is set by both GP and MDM channel. This policy doesn’t support Delete command. This policy doesn’t support setting the value to be 0 again after it was previously set 1. The default value is 0. The MDM policies in Policy CSP will behave as described if this policy value is set 1.

The supported values are: 
0 - Default
1 - The MDM policy is used and the GP policy is blocked.

## Modifications Required
None

## Resources
- [CSP Reference](https://docs.microsoft.com/en-us/windows/client-management/mdm/configuration-service-provider-reference)
- [Policy CSP Details](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-controlpolicyconflict#controlpolicyconflict-mdmwinsovergp)