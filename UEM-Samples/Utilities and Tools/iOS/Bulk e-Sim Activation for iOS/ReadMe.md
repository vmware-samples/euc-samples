# Simplifying eSIM Cellular Plan Activation with Workspace ONE UEM

## Overview

- **Authors**: Robert Terakedis, Christopher Burns
- **Email**: rterakedis@vmware.com, burnsc@vmware.com
- **Date Created**: 2020-08-28
- **Supported Platforms**: Workspace ONE UEM 1908
- **Tested on macOS Versions**: macOS High Sierra

## Purpose

Cellular devices from Apple traditionally required a small, physical Subscriber Identity Module (SIM) card to enable service on a cellular carrier.  The SIM was typically pre-inserted by the carrier, but could be physically swapped if necessary.  Modern devices now include an eSIM, which is a chip built into the device that performs the same function but consumes less internal space.  eSIMs are also more flexible, as it supports any carrier supporting the eSIM standard and eliminates the need for physically touching/modifying the device.

> **NOTE**:  The list of cellular providers is shown on [Apple's Cellular iPad page.](https://www.apple.com/ipad/cellular/)

This sample guidance provides details on how to bulk activate iPad Cellular Plans.

## Table of Contents

- [Activating Cellular Service without MDM](#activating-cellular-service-without-mdm)
- [Automated Cellular Service Activation with Workspace ONE UEM](#automated-cellular-service-activation-with-workspace-one-uem)
  - [Pre-Requisites](#pre-requisites)
  - [Known Carrier eSIM Activation Server URLs](#known-carrier-esim-activation-server-urls)
  - [Activating with API Integration](#Activating-with-API-Integration)
  - [Activating via Workspace ONE UEM Console](#Activating-via-Workspace-ONE-UEM-Console)
- [Considerations and Troubleshooting](#considerations-and-troubleshooting)
  - [Considerations for Device Reset](#considerations-for-device-reset)
  - [Considerations When Bulk Activating](#Considerations-When-Bulk-Activating)
  - [eSIM Activation Troubleshooting](#eSIM-Activation-Troubleshooting)
  - [Pop-Up Notifications Related to Cellular Networks](#Pop-Up-Notifications-Related-to-Cellular-Networks)

## Activating Cellular Service without MDM

Out-of-the-box, eSIM devices don't know with which carrier to activate service.  This is typically solved in consumer purchases by the retailer pre-configuring the device, or the carrier/Apple setting the device-to-carrier association.  Organizations purchasing these devices can also leverage activation URLs, QR Codes, or an App Store App to aid in user-based activation.  

## Automated Cellular Service Activation with Workspace ONE UEM

### Pre-Requisites

When organizations need to add eSIM-enabled devices to their cellular account, they must provide the Mobile Equipment Identity (IMEI) number and eSIM ID (EID) Number.  Your retailer or Apple representative should be able to provide these for purchased devices, preferably as soon as the serial numbers are assigned to the order and shipped.   You can also find these numbers (and associated barcodes) on the outside of the iPad packaging if you need to scan them manually.  

> **NOTE:** If the device is dual-sim enabled (such as for personal and enterprise use), refer to Apple's [Using Dual SIM with an eSIM](https://support.apple.com/en-us/HT209044) page.

> **NOTE:** If the cellular-enabled iPad was purchased direclty from a carrier, the device may be locked to that carrier and the service will enable automatically with device activation.

### Known Carrier eSIM Activation Server URLs

| Carrier Name | eSIM Activation Server URL |
|--------------|----------------------------|
| T-Mobile | https://t-mobile.gdsb.net |
| Verizon | https://2.vzw.otgeuicc.com |
| AT&T | https://cust-001-v4-prod-atl2.gdsb.net |

These activation server URLs are required when issuing custom commands to refresh cellular data via the API.   If you know of one not shown on this list, feel free to enter an Issue via GitHub or send us a pull request!  

> **NOTE:** The server URL should NOT include any trailing slashes ("/").

### Activating with API Integration

Use one of the following RestAPI endpoints to send a *RefreshCellularPlans* command:

- `/devices/commands/`
- `/devices/{deviceID}/commands`

In the parameters of the RestAPI call, you'll need to specify the following:

- command: `CustomMdmCommand`
- customcommandmodel (application/json):

```yaml
{
    “CommandXml” : “<dict>
        <key>RequestType</key>
        <string>RefreshCellularPlans</string>
        <key>eSIMServerURL</key>
        <string>https://eSim.Activation.Server.URL</string>
    </dict>”
}
```

### Activating via Workspace ONE UEM Console

Administrators can activate the eSIM on a per-device basis using the UEM Console.  By clicking into *Device Details* view, you can click on **More Actions > Refresh eSIM**.   The UEM console will prompt for the [Carrier eSIM Activation Server URL](#known-carrier-esim-activation-server-urls), and then clicking **Send** will issue the command to the device.

If more than one device eSIM needs activation, admins can issue a bulk command using the *Custom Command* functionality.  In the *Device List View*, check the boxes to select one or more devices which require eSIM activation.  Click on **More Actions > Custom Commands**.   In the box, you'll need to paste the following Custom MDM Command XML and click **Send** to issue the command to the selected devices.

> **NOTE:** Be sure to supply the correct String value for the *eSIMServerURL* key.

```XML
<dict>
    <key>RequestType</key>
    <string>RefreshCellularPlans</string>
    <key>eSIMServerURL</key>
    <string>https://eSim.Activation.Server.URL</string>
</dict>
```

## Considerations and Troubleshooting

### Considerations for Device Reset

eSIM Activation should be considered a one-time event, as cellular carriers remove device information (IMEI and EID) from activation servers once the eSIM has been activated.  Admins should generally attempt to retain the cell plan on the device when wiping (or resetting content and settings), and prevent users from modifying the cell plan on the device.  To ensure cellular plans are protected, consider the following:

- Ensure a **Restrictions** profile payload is added to the device which unchecks the following restrictions:
  - **Allow eSIM Modification**
  - **Allow Cellular Plan Modification**
  - **Allow Changes to Cellular Data Usage for Apps**
- Consider using the **Network Usage Rules** payload to disable cellular data for non-business apps (like Netflix, Disney+, YouTube, and more)
- Consider avoiding auto-wipe after too many failed passcode attempts, as this deletes the cellular plan details configured in the eSIM.
- Consider unchecking the restriction for **Allow Erase All Contents and Settings** so the user can't acccidentally self-delete the eSIM settings.
- When sending a Device Wipe command, select the option to *Preserve the Data Plan*

### Considerations When Bulk Activating

- Bulk Activation requires network bandwidth, just like OS updates and Enrollment.  Closely monitor network or Internet connection saturation if you start to see odd behavior.
- If bulk provisioning devices, ensure there's no limits placed on WiFi acceess points as to number of concurrent clients, or interference from neighboring access points.
- Ensure you're not running other bulk commands simultaneously, such as OS Upgrades, Application Installs/Upgrades, etc.
- Consider using macOS Caching Services to reduce network load related to Apps, OS Upgrades/Installs, and certain iCloud content.

### eSIM Activation Troubleshooting

If you've attempted to activate an eSIM device and it doesn't seem to work, check the following:

- Verify there aren't pending MDM commands in the **Device Details > Troubleshooting** tab.
- Ensure the device is charged and in a location with cellular service.
- Ensure the device IMEI and EID numbers have been sent to the carrier and tied to an active cellular plan.
- Check for a typo in the eSIM Activation URL sent to the device.
- Check the device has WiFi or tethered data connection and can communicate with the Internet.

### Pop-Up Notifications Related to Cellular Networks

|  Message Displayed | Explanation |
|--------------------|-------------|
| [No SIM Card Installed](https://support.apple.com/en-us/HT201420) | There's no physical SIM card in the SIM slot/tray.  Once the eSIM has been activated, signal strength should be shown in the top corner of the home screen. *If Bulk Activating an eSIM, you can ignore this message about the physical SIM card*. |
| Cellular Plan Ready to be Installed | The cellular provider has added the IMEI and EIDs to a cellular plan and iPadOS is prompting to activate the cellular plan manually. *If Bulk Activating with Workspace ONE UEM, you can ignore this message*. |
| [Carrier Settings Update](https://support.apple.com/en-us/HT201270) | The carrier has made an update available which modifies cellular radio and network settings.  This update should be applied to ensure the device continues working correctly.  |
| Cellular Plan Cannot Be Added | The carrier needs to re-enable the device in their activation server using the IMEI and EID numbers. |
| Unable to Complete Cellular Plan Change |  The device is already activated. |