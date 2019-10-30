# Slack Sample Collection

## Overview
- **Author**: Adam Hardy
- **Email**: ahardy@vmware.com
- **Date Created**: 10/28/2019


## Purpose

A sample of how Slack APIs can be customized and used for Automation workflows in Workspace ONE Intelligence


## Requirements

1. The latest version of [Postman](https://www.getpostman.com) 
2. Workspace ONE Intelligence
3. A Slack instance

## How to use this sample

This collection is a sample for use within Workspace ONE Intelligence.  Please be sure to populate the Webhook URL from your Incoming Webhook integration. 

**Create an Incoming Webhook**

Using the Incoming Webhooks integration to create and send messages to Channels and Users is fairly straightforward, to learn how, please refer to the [Slack Documentation](https://api.slack.com/messaging/webhooks#getting-started)

By default, messages will be sent to the channel configured in the Incoming Webhook integration. This can easily be overridden in the payload body of the request.

*Note:* Messages can only be sent to the channels of which the configuring user is a member.

**Authentication**

To configure this connector in Intelligence, select the *No Authentication* type and enter only the Base URL (Typically `https://hooks.slack.com`). The rest of the path will be used automatically, as defined in the collection.

**Actions in the Collection**

1. **Basic Message** - This is a basic, text-only message action you can use to send to channels or users.
 * Populate the `channel` value with the channel name (#channel) or username (@username) to send to your recipient.
 * Populate `text` with the body of the message
2. **Advanced Format Message** - Slack's Advanced Formating allows for more complex messaging to be displayed to your recipients.
 * Populate the `channel` value with the channel name (#channel) or username (@username) to send to your recipient.
 * `color` can be modified using Hex values
 * Additional features can be used by referring to the [Slack Documentation](https://api.slack.com/messaging/webhooks#advanced_message_formatting)

## Additional Resources
[Slack Webhook Documentation](https://api.slack.com/messaging/webhooks)
[Workspace ONE Intelligence User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-AWT-WS1INT-OVERVIEW.html)
[Custom Connector User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-54333CCC-0E6D-4871-8DEA-3AFAB8378EEC.html)
[Postman Resources](https://www.getpostman.com)
