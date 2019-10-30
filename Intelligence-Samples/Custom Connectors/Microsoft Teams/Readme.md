# Microsoft Teams Sample Collection

## Overview
- **Author**: Adam Hardy
- **Email**: ahardy@vmware.com
- **Date Created**: 10/28/2019


## Purpose

A sample of how Microsoft Teams APIs can be customized and used for Automation workflows in Workspace ONE Intelligence


## Requirements

1. The latest version of [Postman](https://www.getpostman.com) 
2. Workspace ONE Intelligence
3. A Microsoft Office 365 subscription with Teams

## How to use this sample

This collection is a sample for use within Workspace ONE Intelligence.  Please be sure to populate the Webhook URL(s) from your channels. 

Send messages and cards to Microsoft Teams using the Incoming Webhook integration.  An Incoming Webhook must be configured for each channel using the Connectors setup options.

**Generating a Webhook URL for a Channel**

In order to send messages to a channel, we must first add a webhook integration in Teams.  To do this, open your Teams app, select *More Options* next to your desired channel and choose *Connectors*. Find the *Incoming Webhook* connector and configure accordingly. You should use the Webhook URL as the full URL within the Postman Request. For more details on this setup, refer to [Microsoft's Documentation](https://docs.microsoft.com/en-us/microsoftteams/platform/concepts/connectors/connectors-using#setting-up-a-custom-incoming-webhook).

**Note:** Each request can only be associated with one channel in Microsoft Teams, so if you'd like the ability to send messages to multiple channels, duplicate the request in Postman and add the new Webhook URL. Be sure to save the request with a descriptive name specifying the channel to which the request is associated.

**Authentication**

To configure this connector in Intelligence, select the *No Authentication* type and enter only the Base URL (Typically `https://outlook.office.com`). The rest of the path will be used automatically, as defined in the collection.

**Actions in this Collection**
1. **Create Simple Message** - This is a simple, text-based message that will be sent to the channel configured in the webhook URL.
2. **Create Card** - This is a sample of one type of card that can show a formatted message including lists, images, buttons, and more. To learn more about the types of cards that can be used, see [Microsoft's Card Reference](https://docs.microsoft.com/en-us/microsoftteams/platform/concepts/cards/cards-reference)
 * `@context` and `@type` define what kind of card should be displayed
 * `themeColor` can be modified to highlight the card using a HEX string
 * `sections` can be modified to change the overall format of the card according to [Microsoft's Card Reference](https://docs.microsoft.com/en-us/microsoftteams/platform/concepts/cards/cards-reference)

## Additional Resources
[Generating a Microsoft Teams Incoming Webhook](https://docs.microsoft.com/en-us/microsoftteams/platform/concepts/connectors/connectors-using#setting-up-a-custom-incoming-webhook)
[Microsoft Teams Card Reference](https://docs.microsoft.com/en-us/microsoftteams/platform/concepts/cards/cards-reference)
[Workspace ONE Intelligence User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-AWT-WS1INT-OVERVIEW.html)
[Custom Connector User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-54333CCC-0E6D-4871-8DEA-3AFAB8378EEC.html)
[Postman Resources](https://www.getpostman.com)
