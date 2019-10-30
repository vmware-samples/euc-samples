# Splunk Sample Collection

## Overview
- **Author**: Adam Hardy
- **Email**: ahardy@vmware.com
- **Date Created**: 10/28/2019


## Purpose

A sample of how Splunk Data Input APIs can be customized and used for Automation workflows in Workspace ONE Intelligence


## Requirements

1. The latest version of [Postman](https://www.getpostman.com) 
2. Workspace ONE Intelligence
3. A Splunk Enterprise Server

## How to use this sample

This collection is a sample for use within Workspace ONE Intelligence.  Please be sure to populate all variable fields with the values from your instance. Including: BaseURL and Token.

**Configuring Data Inputs**
In Splunk, navigate to Settings > Data > Data Inputs > HTTP Event Collector and configure all required settings.  Once configured, a **Token** is generated for use in the Authentication header.

**Authentication**
Use the Basic Authentication type and use `x` as the Username and `token-value` as the password to send data to your desired collector.

If applicable, you can use Splunk's token header authentication instead, simply choose the No Authentiation option in Intelligence and be sure your token is populated in the header within the Postman collection before uploading.

**Configuring the Action**
To add data into Splunk, it is recommeded to utilize the Dynamic Values present in the Automation configuration screen. This will create a record with contextual data about your devices, users, security events, or other data as needed by your use-case.

Be sure to configure your **sourcetype** to reflect from where this data is sent (Workspace ONE Intelligence) or to define the type of data sent (Device Posture, User, Security Threats, etc.).  Populate the **event** with details about the entity using any static or dynamic value in the system.

**Additional Info**

For more information, check out Splunk's [API Reference](https://docs.splunk.com/Documentation/Splunk/8.0.0/RESTREF/RESTinput#services.2Fcollector)
(search for `services/collector` and `services/collector/event`)

## Additional Resources
[Splunk API Reference](https://docs.splunk.com/Documentation/Splunk/8.0.0/RESTREF/RESTinput#services.2Fcollector)
[Workspace ONE Intelligence User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-AWT-WS1INT-OVERVIEW.html)
[Custom Connector User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-54333CCC-0E6D-4871-8DEA-3AFAB8378EEC.html)
[Postman Resources](https://www.getpostman.com)
