# Privacy Preferences Policy Control for macOS Mojave 10.14+

## Overview

- **Author(s)**: Robert Terakedis
- **Email(s)**: rterakedis@vmware.com
- **Date Created**: 11/8/2018
- **Supported Platforms**: Workspace ONE UEM version 1810
- **Tested on macOS Versions**: macOS Mojave (10.14+)

## Table of Contents

- [Purpose](#purpose)
- [Determining Required Policies](#determining-required-policies)
  - [Testing Methodology](#testing-methodology)
  - [TCC DB Reset](#tcc-db-reset)
- [Common Binaries to Whitelist](#common-binaries-to-whitelist)
- [List of Binaries to Verify](#list-of-binaries-to-verify)
- [Change Log](#change-log)
- [Additional Resources](#additional-resources)

## Purpose

With macOS Mojave, User Consent for Data Access can be managed via MDM through the "Privacy Preferences Policy Control" (PPPC) payload.  The settings established through the PPPC payload affect the Transparency Consent and Control (TCC) database, allowing administrators to grant consent to data on behalf of the user for User-Approved MDM enrollments.  More details about User Consent for Data Access can be found on [VMware's TechZone](https://techzone.vmware.com/blog/vmware-workspace-one-uem-apple-macos-mojave-user-consent-data-access)

Since it's introduction in the macOS Mojave betas, a number of resources have emerged on the Internet aimed at helping macOS admins discover and track the various PPPC rules they may need in their environment.   The goal of this VMware Sample is to bring together those various resources into a single reference point.

> **Please feel free to send us pull requests for updates and add any TCC whitelists for apps that you've discovered!**

## Determining Required Policies

The following outlines some basic, high-level steps to help you determine what Privacy Preferences Policies are needed in your environment.

### Testing Methodology

1. Start with a clean/fresh installation of macOS Mojave (such as a VMware Fusion VM freshly installed with a snapshot taken)
2. Install the software you need to verify and use the software for common workflows
3. Note the permission requests that pop up and the type of permissions required (User data, Accessibility, Apple Events, etc)
4. If necessary, you can run the following commands to help discover the requested permissions from the Unified Log:
  1. `/usr/bin/log show --predicate 'subsystem == "com.apple.TCC"' | grep Prompting`
  2. `/usr/bin/log stream --debug --predicate 'subsystem == "com.apple.TCC" AND eventMessage BEGINSWITH "AttributionChain"'`
  3. `log stream --debug --predicate 'subsystem == "com.apple.TCC" AND eventMessage BEGINSWITH "AttributionChain" OR eventMessage CONTAINS "synchronous to com.apple.tccd.system"'`
5. Obtain the "Code Requirement" for the app (or receiving app) by running the following command:  `codesign --display -r - /path/to/binary/or/application`
6. Reset the TCC Database Decisions using `/usr/bin/tccutil` (See [TCC DB Reset](#tcc-db-reset) below..)ß

> **NOTE:**  Carl Ashley posted a great blog about [how to read TCC logs in macOS](https://carlashley.com/2018/09/06/reading-tcc-logs-in-macos/).

> **NOTE:**  You can also review the TCC database *after* clicking the button to whitelist the app.   Run the command `echo ".dump" | sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db` and `echo ".dump" | sudo sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db` to view the entries in the TCC databases.   You will not be able to read the TCC.db if Terminal is not granted permissions (SystemPolicyAllFiles)

### TCC DB Reset

1. Use the `tccutil reset <service name>` command within Terminal.app to reset one (or more) of the affected services (Great write-up on this at [Helping your users reset TCC Privacy Policy Decisions](https://www.macblog.org/post/reset-tcc-privacy/)):

    ```
    Accessibility
    AddressBook
    All
    AppleEvents
    Calendar
    Camera
    Facebook
    LinkedIn
    Liverpool
    Location
    MediaLibrary
    Microphone
    Photos
    PhotosAdd
    PostEvent
    Reminders
    ShareKit
    SinaWeibo
    Siri
    SystemPolicyAllFiles
    SystemPolicyDeveloperFiles
    SystemPolicySysAdminFiles
    TencentWeibo
    Twitter
    Ubiquity
    Willow
    ```

2. Or... use a TCC Reset Script such as [`tcc-reset.py` by Matthew Warren](https://gist.github.com/haircut/aeb22c853b0ae4b483a76320ccc8c8e9)

## Common Binaries to Whitelist

The following list of binaries should be common for most admins leveraging UEM and scripting to manage macOS:

> **NOTE:** As of Workspace ONE UEM version 1810, a PPPC profile is automatically delivered to all enrolled macOS devices to automatically whitelist all eventing and access required by the Workspace One Intelligent Hub processes.  Pre-1810 Consoles can deploy the whitelist as [Custom XML](https://support.workspaceone.com/articles/360009247374)

| Description | Identifier (Type) | Code Requirement | Relevant Permissions | Apple Event Receivers ++ Code Requirement? |
| ----------- | ------------------| ---------------- | -------------------- | ------------------------------------------ |
| **Allow Terminal.app relevant permissions for access and Eventing** | `com.apple.Terminal` (bundle ID) | `identifier “com.apple.Terminal” and anchor apple` | <ul><li>SystemPolicyAllFiles</li><li>Accessibility</li><li>SysAdminFiles</li></ul> | <ul><li>`com.apple.systemuiserver` (bundle id) ++ `identifier “com.apple.systemuiserver” and anchor apple`</li><li>`com.apple.systemevents` (bundle id) ++ `identifier “com.apple.systemevents” and anchor apple`</ul> |
| **Allow AppleEvents control for osascript (AppleScript)** | `/usr/bin/osascript` (path) | `identifier “com.apple.osascript” and anchor apple` | <ul><li>None</li></ul> | <ul><li>`com.apple.systemuiserver` (bundle id) ++ `identifier “com.apple.systemuiserver” and anchor apple`</li><li>`com.apple.systemevents` (bundle id) ++ `identifier “com.apple.systemevents” and anchor apple`</li><li>`com.apple.finder` (bundle id) ++ `identifier “com.apple.finder” and anchor apple`</li><li>`com.microsoft.Outlook` (bundle id) ++ `identifier "com.microsoft.Outlook" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = UBF8T346G9`</li></ul> |
| **Allow Events and Access for Installer** | `/usr/bin/installer` (path) | `identifier “com.apple.installer” and anchor apple` | <ul><li>SysAdminFiles</li></ul> | <ul><li>`com.apple.systemevents` (bundle id) ++ `identifier “com.apple.systemevents” and anchor apple`</li></ul> |
| **VMware Horizon Client** | `com.vmware.horizon` (bundle ID)| `identifier "com.vmware.horizon" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = EG7KH642X6` | <ul><li>Accessibility</li></ul> | ------------------------------------------ |
| **VMware Fusion 11 (1 of 2)** | `com.vmware.fusion` (bundle ID) | `identifier "com.vmware.fusion" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = EG7KH642X6` | <ul><li>Accessibility</li></ul> | ------------------------------------------ |
| **VMware Fusion 11 (2 of 2)** | `com.vmware.vmware-vmx` (bundle ID) | `identifier "com.vmware.vmware-vmx" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = EG7KH642X6` | <ul><li>Accessibility</li></ul> | ------------------------------------------ |
| **Adobe Photoshop** | `com.adobe.Photoshop` (bundle ID) | `identifier "com.adobe.Photoshop" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = JQ525L2MZD` | <ul><li>Accessibility</li></ul> | ------------------------------------------ |
| **Bomgar SCC** | `com.bomgar.bomgar-scc` (bundle ID) | `identifier "com.bomgar.bomgar-scc" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = B65TM49E24` | <ul><li>Accessibility</li><li>PostEvent</li></ul> | <ul><li>`com.apple.systemevents` (bundle id) ++ `identifier “com.apple.systemevents” and anchor apple`</li></ul> |
| **Citrix Receiver (1 of 2)** | `com.citrix.receiver.nomas` (bundle ID) | `anchor apple generic and identifier "com.citrix.receiver.nomas" and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */ or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = S272Y5R93J)` | <ul><li>Accessibility</li></ul> | <ul><li>`com.apple.systempreferences` (bundle ID) ++ `identifier "com.apple.systempreferences" and anchor apple`</li><li>`com.citrix.XenAppViewer` (bundle ID) ++ `identifier "com.citrix.XenAppViewer" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = S272Y5R93J`</li><li>`com.citrix.CitrixReceiverLauncher` (bundle ID) ++ `anchor apple generic and identifier "com.citrix.CitrixReceiverLauncher" and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */ or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = S272Y5R93J)`</li><li>`com.apple.systemuiserver` (bundle id) ++ `identifier “com.apple.systemuiserver” and anchor apple`</li><li>`com.apple.systemevents` (bundle id) ++ `identifier “com.apple.systemevents” and anchor apple`</li><li>`com.apple.finder` (bundle id) ++ `identifier “com.apple.finder” and anchor apple`</li></ul> |
| **Citrix Receiver (2 of 2)** | `com.citrix.XenAppViewer` (bundle ID) | `identifier "com.citrix.XenAppViewer" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = S272Y5R93J` | <ul><li>Accessibility</li></ul> | <ul><li>`com.citrix.XenAppViewer` (bundle ID) ++ `identifier "com.citrix.XenAppViewer" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = S272Y5R93J`</li><li>`com.citrix.CitrixReceiverLauncher` (bundle ID) ++ `anchor apple generic and identifier "com.citrix.CitrixReceiverLauncher" and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */ or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = S272Y5R93J)`</li><li>`com.apple.systempreferences` (bundle ID) ++ `identifier "com.apple.systempreferences" and anchor apple`</li><li>`com.apple.systemuiserver` (bundle id) ++ `identifier “com.apple.systemuiserver” and anchor apple`</li><li>`com.apple.systemevents` (bundle id) ++ `identifier “com.apple.systemevents” and anchor apple`</li><li>`com.apple.finder` (bundle id) ++ `identifier “com.apple.finder” and anchor apple`</li></ul> |
| **Druva InSync Client** | `com.druva.inSync` (bundle ID) | `identifier "com.druva.inSync" and anchor apple generic and certificate leaf[subject.CN] = "3rd Party Mac Developer Application: Druva Technologies PTE LTD (JN6HK3RMAP)" and certificate 1[field.1.2.840.113635.100.6.2.1] /* exists */` | <ul><li>SystemPolicyAllFiles</li></ul> | ------------------------------------------ |
| **ESET Endpoint Antivirus ** | `com.eset.eea.6` (bundle ID) | `identifier "com.eset.eea.6" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = P8DQRXPVLP` | <ul><li>SystemPolicyAllFiles</li></ul> | ------------------------------------------ |
| **Microsoft Outlook** | `com.microsoft.Outlook` (bundle ID) | `identifier "com.microsoft.Outlook" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = UBF8T346G9` | -------------------- | <ul><li>`com.microsoft.SkypeForBusiness` (bundle id) ++ `identifier "com.microsoft.SkypeForBusiness" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = AL798K98FX`</li></ul> |
| **Microsoft Remote Desktop Client** | ------------------| ---------------- | -------------------- | ------------------------------------------ |
| **Microsoft Skype for Business** | `com.microsoft.SkypeForBusiness` (bundle ID) | `identifier "com.microsoft.SkypeForBusiness" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = AL798K98FX` | -------------------- | <ul><li>`com.microsoft.Outlook` (bundle id) ++ `identifier "com.microsoft.Outlook" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = UBF8T346G9`</li></ul> |
| **Zoom Client (1 of 2)** | `us.zoom.xos` (bundle ID) | `identifier "us.zoom.xos" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = BJ4HAAB9B3` | <ul><li>Accessibility</li></ul> | ------------------------------------------ |
| **Zoom Client (2 of 2)** | `us.zoom.pluginagent` (bundle ID) | `identifier "us.zoom.pluginagent" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = BJ4HAAB9B3` | -------------------- | <ul><li>`com.microsoft.Outlook` (bundle id) ++ `identifier "com.microsoft.Outlook" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = UBF8T346G9`</li></ul> |
| **Zoom Presence** | `us.zoom.ZoomPresence` (bundle ID) | `identifier "us.zoom.ZoomPresence" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = BJ4HAAB9B3` | <ul><li>SystemPolicyAllFiles</li></ul> | ------------------------------------------ |

## List of Binaries to Verify

More binaries can be found at the following community pages:

- https://docs.google.com/spreadsheets/d/1sai3Q8qj9HdyDJfcSAchRELD0mOpik1NPYxr0F9AJRc/edit#gid=1015292594
- https://github.com/rtrouton/privacy_preferences_control_profiles
- https://github.com/ducksrfr/mac_admin/tree/master/Privacy%20Preferences%20Policy%20Control%20Profiles

## Change Log

- 11/8/2018: Created Initial File

## Additional Resources

- [Workspace ONE UEM and User Consent for Data Access](https://techzone.vmware.com/blog/vmware-workspace-one-uem-apple-macos-mojave-user-consent-data-access)
- [Diagnosing Privacy Protection Problems in Catalina](https://eclecticlight.co/2020/01/07/diagnosing-privacy-protection-problems-in-catalina/)
- [Helping your users reset TCC Privacy Policy Decisions](https://www.macblog.org/post/reset-tcc-privacy/)
- [Carl Ashley's `tccprofile` project](https://github.com/carlashley/tccprofile)
- [Reading TCC Logs in macOS](https://carlashley.com/2018/09/06/reading-tcc-logs-in-macos/)
- [Code-Signing Scripts for PPPC WhiteListing](https://carlashley.com/2018/09/23/code-signing-scripts-for-pppc-whitelisting/)
- [The #tcc channel on the MacAdmins Slack](https://macadmins.herokuapp.com)
- [Custom XML for PPPC profile for Workspace ONE Intelligent Hub (Pre-1810 Console Versions)](https://support.workspaceone.com/articles/360009247374)
