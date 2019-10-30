# Zendesk Sample Collection

## Overview
- **Authors**: Adam Hardy, Shruti Phanse
- **Email**: ahardy@vmware.com, sphanse@vmware.com
- **Date Created**: 10/28/2019


## Purpose

A sample of how Zendesk APIs can be customized and used for Automation workflows in Workspace ONE Intelligence


## Requirements

1. The latest version of [Postman](https://www.getpostman.com) 
2. Workspace ONE Intelligence
3. A Zendesk instance with Agent access

## How to use this sample

This collection is a sample for use within Workspace ONE Intelligence.  Please be sure to populate all variable fields with the values from your instance. Including: BaseURL and Token.

**Permissions**
The *Create Ticket* API requires the *Agent* role.

**Authentication**
In most cases, you should be able to use *Basic Authentication* with the agent's username and password.

*Note:* If 2-factor authentication is enabled, you must use an API token or the OAuth flow. 

To use an API Token, use *Basic Authentication* and populate the username field with your `username` and the password field with `token:{api_token}`.

OAuth can be configured using the Intelligence *OAuth Authentication* type.

More information on authentication requirements can be found at [Zendesk API Security and Authentication ](https://developer.zendesk.com/rest_api/docs/support/introduction#security-and-authentication)

**Customizing the Requests**
This collection comes with a sample of how to create a ticket. To further customize the request for your needs, please see the [API Reference](https://developer.zendesk.com/rest_api/docs/support/tickets#create-ticket)

## Additional Resources
[Zendesk API Reference](https://developer.zendesk.com/rest_api/docs/support/tickets#create-ticket)
[Workspace ONE Intelligence User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-AWT-WS1INT-OVERVIEW.html)
[Custom Connector User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-54333CCC-0E6D-4871-8DEA-3AFAB8378EEC.html)
[Postman Resources](https://www.getpostman.com)
