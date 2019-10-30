# Atlassian Cloud Sample Collection

## Overview
- **Author**: Adam Hardy
- **Email**: ahardy@vmware.com
- **Date Created**: 10/28/2019


## Purpose

A sample of how Atlassian APIs can be customized and used for Automation workflows in Workspace ONE Intelligence


## Requirements

1. The latest version of [Postman](https://www.getpostman.com) 
2. Workspace ONE Intelligence
3. An Atlassian Cloud or Jira instance
4. An admin account in Atlassian with the roles and permissions that allow generating a token for API access


## How to use this sample

This collection is a sample for use within Workspace ONE Intelligence.  Please be sure to populate all variable fields with the values from your instance. Including: BaseURL and Token.

Additionally, you can add other custom field types to this request based on your needs. Check the Jira API documentation to learn more.

There are 3 actions included in this sample:
1. Create Jira Bug
2. Create Jira Task
3. Create Service Desk Request
**Note:** Please read the descriptions for these requests in the Postman collection for more information

**Permissions Required** 
*Browse projects* and *Create issues* [project permissions](https://confluence.atlassian.com/x/yodKLg) for the project in which the issue or subtask is created.

**Authentication**
For Authentication with the API, use the **Basic Authentication** type with your Admin username and populate the Password field with a generated API token.To generate a Token for use with the API, follow these instructions to [Generate account API tokens](https://confluence.atlassian.com/cloud/api-tokens-938839638.html)

For more information on Atlassian APIs, please check the [Atlassian API Reference](https://developer.atlassian.com/cloud/jira/platform/rest/v2/#api-rest-api-2-issue-post)

## Additional Resources
[Atlassian API Reference](https://developer.atlassian.com/cloud/jira/platform/rest/v2/#api-rest-api-2-issue-post)
[Workspace ONE Intelligence User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-AWT-WS1INT-OVERVIEW.html)
[Custom Connector User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-54333CCC-0E6D-4871-8DEA-3AFAB8378EEC.html)
[Postman Resources](https://www.getpostman.com)
