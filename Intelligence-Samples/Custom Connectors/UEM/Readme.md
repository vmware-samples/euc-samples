# UEM Custom MDM Commands Sample Collection

## Overview
- **Author**: Robert Terakedis
- **Email**: rterakedis@vmware.com
- **Date Created**: 2021-09-27

## Purpose

A sample of how you can use the MDM Rest API to issue Custom MDM Commands to a device.   This postman collection contains the following custom commands:

1. RestartDevice
2. RecommendationCadence
3. RefreshCellularPlan (eSim Activation --> T-Mobile, Verizon, and AT&T)

## Requirements

1. The latest version of [Postman](https://www.getpostman.com) 
2. Workspace ONE Intelligence
3. Workspace ONE UEM
4. An enrolled device
5. An administrator account with API Access enabled and sufficient role-based permissions to run the API tasks.
6. An API Key (as generated at **Settings > System > Advanced > API > REST API**).

## How to prepare this sample for import

This collection is a sample for use within Workspace ONE Intelligence.  Please be sure to populate all variable fields with the values from your instance. Follow this process to prepare the Postman Collection for uploading to Intelligence:

1. Download the Custom UEM API Calls postman collection locally and open it in Postman.
2. Note the 5 separate UEM API calls included:  *RestartDevice, RecommendationCadence, RefreshCellularPlans* (3 separate instances of RefreshCellularPlans)
3. Click on the line that says "Post" for the *RestartDevice* API Call.  In the *Headers* section, replace the **VALUE** for **aw-tenant-code** with your API Key (see oAuth note below)
4. Click Save to save the updated API call.
5. Repeat Steps 3 and 4 for the other API calls.
6. Right-Click on the **Custom UEM API Calls** collection and click **Export**
7. Save the collection export as Postman version 2.1 to your device.

> NOTE:  The *aw-tenant-code* (or API Key) is only necessary if you'll be using basic authentication for Intelligence to authenticate to UEM.   If you plan to use [oAuth](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/UEM_ConsoleBasics/GUID-BF20C949-5065-4DCF-889D-1E0151016B5A.html#datacenter-and-token-urls-for-oauth-20-support-2), the API key is disregarded as it is already part of the oAuth token.

## Build a Workspace ONE Intelligence Custom Connector

Once you've prepared the Postman collection for import, you are ready to use the collection as the starting point for your Intelligence Connector.

> **NOTE:** If you configure your Connector API authentication for oAuth, Workspace ONE Intelligence ignores the authentication scheme provided in the Postman Collection.

> **NOTE #2:** The Base URL configured in the Intelligence Connector Settings will override the Base URL defined in the Postman Collection.

1. Within Workspace ONE Intelligence, click on **Integrations** then click **View** in the *Workflow Connectors* box
1. Click **Add Custom Connector**
1. Enter a Connector Name (such as *Custom MDM Command*), and enter API authentication details for the payload body and click **OK**
1. Click **Import Actions**.  Browse to your modified Postman collection and click **Open**
1. Click the three dots next to the **Action Name** (*RestartDevice*) and click **Configure**.   Note the parameters and body that the import brought in from the Postman Collection.  Workspace ONE Intelligence will not show you the *aw-tenant-code*, but it is there if you provide it in the collection.   Click **Cancel**
1. Click the three dots next to the **Action Name** and click ** test**.  Replace the **id** value with the serial number of an iOS device and click ** test**.   Ensure the test is successful and you see the device restart. 
1. Optionally, you can repeat the test for the other Custom MDM Commands you'd like to use.

## Use the Custom Connector in an Intelligence Automation

With the custom connector in place, you can now use the connector to trigger custom MDM commands against devices in your environment.

> **CAUTION:** When setting up a Workflow, build it with a highly limited filter (<10 devices) and a manual trigger.  Test and validate expected results *before* automating against your entire fleet!

1. In Workspace ONE Intelligence, click **Automations**
1. Click **Add > Custom Workflow**
1. Click **Category > Workspace ONE UEM > Devices**
1. Enter a name and description for the workflow (such as *RecommendationCadence Workflow*)
1. For an initial test of the workflow, set the *Trigger* to **Manual**
1. Enter your initial filter.  Some useful filters may include:
  * Filter by a specific testing Organization Group:  (Devices > Device Organization Group Name) | Equals | (Enter a specific UEM Org Group Name)
  * Filter by a specific testing user:  (Devices > User Name) | Equals | (Enter a specific enrollment User Name)
  * Filter by a specific serial number:  (Devices > Serial Number normalized) | Equals | (Specific Device Serial Number)
7. After configuring your filter, click the **View** button in the "Filter Results Summary" box to see how many devices are potentially targeted by your filter.
1. Click the plus sign **(+)** to add one or more actions:
1. Select the Custom MDM Command connector and choose the specific Action to run (CustomMDMCommand-RecommendationCadence)
1. Remove the value for **id** and replace it with a selection by clicking the Lookup Value button to the right.  Choose **Devices > Serial Number (normalized)**.   Intelligence resolves this to the lookup value **${airwatch.device._device_serial_number}**
1. Optionally add any additional actions you want to test.
1. Click **Save** in the top right corner.
1. Select your new workflow in the list of Workflows.  Click **More > Enable**
1. Enable ** One-time manual run** and click **Enable**
1. Click **More > Run** and click **Yes** to manually run the workflow on filtered devices.
 
## Validating your Workflow ##

Within Workspace ONE UEM, go to the device details for one of the devices affected by your filter.  You can view delivery of the command from the troubleshooting tab in the device details (**More > Troubleshooting**).  Note the two events that happen:

* Custom Command Requested
* Custom Command Confirmed

You can also validate the activity in Workspace ONE Intelligence:

* With your workflow selected in the list of Intelligence Automation Workflows, click **Activity**
* Note the status column showing *Active* and *Complete*

## Scaling your Workflow to More Devices ##

You have two options here: create a new workflow or edit the existing workflow.   In either case, when you finish editing the workflow and go to Save it, you may be asked whether to enable a One-Time Manual Run.

* If you save & enable with *One Time Manual Run* **Disabled**, the enabled workflow only takes Action against *new* devices that populate into the filter.   In other words, the workflow does not run against devices currently known within the filter.
* If you save & enable with *One Time Manual Run* **Enabled**, the enabled workflow runs against all existing devices currently known within the filter **AND** new devices that later fall into the filter.

## Tips for Creating your Postman Collection

If you use Postman to create a collection of additional UEM API calls to use in Intelligence Automations, you'll need to keep the following tips in mind:

* Be mindful of the HTTP Verb:  Post, Get, Update, etc.  If you use the wrong one, you'll most likely see HTTP 404 responses.
* Make use of *Environments* in Postman to enable rapid testing or testing against different APIs using different credentials or variable values.
* While variables (sourced from environments or Collections) are a great way to make Collections shareable, they may not be helpful if you intend to upload the collection to Intelligence.   If the collection is used as an import for Automation actions, be sure you're hard coding necessary values (such as the *aw-tenant-code) in each API call.


## Additional Resources
* [Workspace ONE UEM API Reference](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/UEM_ConsoleBasics/GUID-BF20C949-5065-4DCF-889D-1E0151016B5A.html)
* [Workspace ONE UEM Rest API oAuth Reference](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/UEM_ConsoleBasics/GUID-BF20C949-5065-4DCF-889D-1E0151016B5A.html#datacenter-and-token-urls-for-oauth-20-support-2)
* [Workspace ONE Intelligence User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-AWT-WS1INT-OVERVIEW.html)
* [Custom Connector User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/intelligence-documentation/GUID-27_intel_custom_connectors.html)
* [Postman Documentation](https://learning.postman.com/docs/getting-started/introduction/)
* [RecommendationCadence Documentation](https://developer.apple.com/documentation/devicemanagement/settingscommand/command/settings/softwareupdatesettings) and [WWDC Video](https://developer.apple.com/wwdc21/10129)

