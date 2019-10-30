# PagerDuty Sample Collection

## Overview
- **Authors**: Adam Hardy, Shruti Phanse
- **Email**: ahardy@vmware.com, sphanse@vmware.com
- **Date Created**: 10/28/2019


## Purpose

A sample of how PagerDuty APIs can be customized and used for Automation workflows in Workspace ONE Intelligence


## Requirements

1. The latest version of [Postman](https://www.getpostman.com) 
2. Workspace ONE Intelligence
3. A PagerDuty instance
4. An admin account in PagerDuty with the roles and permissions that allow generating a token for API access


## How to use this sample

This collection is a sample for use within Workspace ONE Intelligence.  Please be sure to populate all variable fields with the values from your instance. Including: BaseURL and Token.

Additionally, you can customize the requests to include fields that are required by your incident that may not be included in this collection by default.

To generate a Token for use with the API, follow these instructions to [Generate account API tokens](https://v2.developer.pagerduty.com/docs/authentication)

Properly creating an Incident requires:
* Updating the Authorization header to match the token value of your instance
* Updating the "service.id", "service.type", and "service.summary" to match that of the values in your instance.

For more information on PagerDuty APIs, please check the [PagerDuty API Reference](https://api-reference.pagerduty.com/#!/Incidents/post_incidents)

## Additional Resources
[PagerDuty API Reference](https://api-reference.pagerduty.com/#!/Incidents/post_incidents)
[Workspace ONE Intelligence User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-AWT-WS1INT-OVERVIEW.html)
[Custom Connector User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-54333CCC-0E6D-4871-8DEA-3AFAB8378EEC.html)
[Postman Resources](https://www.getpostman.com)
