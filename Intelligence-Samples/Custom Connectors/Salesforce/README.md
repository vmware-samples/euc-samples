# EUC-samples is now hosted https://github.com/euc-oss/euc-samples
# This repo is no longer maintained

# Salesforce Sample Collection

## Overview
- **Author**: Andreano Lanusse
- **Email**: alanusse@vmware.com
- **Date Created**: 10/28/2019


## Purpose

A sample of how Salesforce REST APIs can be customized and used for Automation workflows in Workspace ONE Intelligence


## Requirements

1. The latest version of [Postman](https://www.getpostman.com) 
2. Workspace ONE Intelligence
3. A Salesforce instance
4. An admin account in Salesforce with the roles and permissions that allow API access


## How to use this sample

This collection is a sample for use within Workspace ONE Intelligence.  Please be sure to populate all variable fields with the values from your instance. Including: BaseURL, OAuth2 Token URL, Client Secret and Clietn ID.

Additionally, you can customize the requests to include fields that are required by your ticket-type that may not be included in this collection by default.


**Set Up OAuth 2.0 in Salesforce**

In order to call the Salesforce API, OAuth authentication is required and must be enable on your salesforce instance.

To setup OAuth 2.0 refer to the salesforce documentation - Topic [Step Two: Set Up Authorization](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/quickstart_oauth.htm).


**Authentication**

To configure this connector in Intelligence, select the *OAuth 2.0* type and enter the the following:
1. Base URL (Typically `https://login.salesforce.com`)
2. OAuth2 Token URL (Typically `https://login.salesforce.com/services/oauth2/token`)
3. Client Secret
4. Client ID


**Actions in this Collection**
1. **Create Case** - This acton will create a new case object in salesforce.

For more information on Salesforce REST APIs, please check the API Explorer on Salesforce [developer site](https://developer.salesforce.com/docs/api-explorer/sobject/)

## Additional Resources
[ServiceNow API Documentation](https://developer.servicenow.com/app.do#!/rest_api_doc?v=madrid&id=r_TableAPI-POST)
[Workspace ONE Intelligence User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-AWT-WS1INT-OVERVIEW.html)
[Custom Connector User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-54333CCC-0E6D-4871-8DEA-3AFAB8378EEC.html)
[Postman Resources](https://www.getpostman.com)
