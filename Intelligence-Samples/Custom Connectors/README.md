# Workspace ONE Intelligence Custom Connector Samples

## Overview
- **Authors**: Andreano Lanusse, Adam Hardy
- **Email**: alanusse@vmware.com, ahardy@vmware.com
- **Date Created**: 10/28/2019
- **Supported Platforms**: Workspace ONE Intelligence


## Purpose

Workspace ONE Intelligence Automation provides the ability for you to use your own API services in addition to the out-of-the box connectors.  You can easily add any REST API service as a Custom Connector by importing Postman Collections.

Included in this repository is a list of Postman Collection samples that can be immediately imported into Intelligence and used in Automation workflows, with the added benefit of demonstrating how you can create Collections with your own REST API enabled services.

* VMware Carbon Black - perform device quarantine action
* Atlassian JIRA - create JIRA bugs, tasks and service desk request
* Microsoft Teams - create simple messages and cards
* PagerDuty - create incidents
* Salesforce - create cases
* Service Now - create problems and tickets
* Slack - create basic message and advanced formatted message
* Splunk - add data input
* Zendesk - create tickets

## Requirements

In order to create your own Postman collections, the following is required:

1. The latest version of [Postman](https://www.getpostman.com) 
2. Workspace ONE Intelligence


## How to create a Postman Collection for use within Automation workflows

In order to create a valid Collection to Import as a Custom Connector you need to:

1. Download the latest version of [Postman](https://www.getpostman.com) 
2. Create a collection using the process outlined in [Use Postman for Custom Connections](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-8A79C3A5-6061-47D3-BE85-4AD4593872EB.html#GUID-8A79C3A5-6061-47D3-BE85-4AD4593872EB)
3. It is important to save the tested response of each Postman request as an Example, as the Open API specification requires this step. To do this, follow instructions on the [Postman Responses Documenation](https://learning.getpostman.com/docs/postman/sending_api_requests/responses).
* *Note:* All samples included in this repository already have saved responses so you can use them as-is. However, if you add new requests they should be tested and responses saved to prevent import issues.
4. Export the Collection as **Collection v2.1**
5. Within Workspace ONE Intelligence, navigate to *Settings > Integrations > Automation Connections > Add Custom Connection* and add your connector detail, as specified in the sample instructions.

Note: Consider adding headers as `Content-Type: application/json`. If you do not add headers as the content type JSON, the APIs can default to XML and XML does not work with custom connections.


## Additional Resources
[Custom Connector User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-54333CCC-0E6D-4871-8DEA-3AFAB8378EEC.html)
[Workspace ONE Intelligence User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-AWT-WS1INT-OVERVIEW.html)
[Postman Resources](https://www.getpostman.com)
