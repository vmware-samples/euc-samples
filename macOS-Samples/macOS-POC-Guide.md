# macOS Proof-of-Concept Guide #
As organizations are embracing employee choice or embarking on their own [“Digital Transformation,”](https://techzone.vmware.com/blog/i-talked-160-customers-past-year-about-their-euc-plans-heres-what-i-learned) one thing became clear:  there’s a number of “accidental macOS admins.”  This guide aims to help anyone new to the macOS Platform (iOS/Android admins, traditional Windows admins, or newbies to PCLM/MDM/EMM/UEM) and focuses on enabling a user-driven, out-of-box enrollment flow using integrations with Apple Business Manager (or Apple School Manager).

>As always, contributions from the community are welcome, so if you find something missed (or have something to share) as you go through this guide, send us a pull request!

## THE TYPICAL "DON'T DO THIS IN YOUR PRODUCTION ENVIRONMENT" WARNING: ##
This is general guidance to help you self-configure a macOS Proof-of-Concept in a lab or non-production/non-critical environment.  This guide is not actively maintained by VMware employees, and the documented procedures may change or become invalidated over time.   

**DO NOT DO THIS IN YOUR PRODUCTION ENVIRONMENT!**

> There.. we said it.  Use your testing environment, a TestDrive Sandbox, or a self-hosted testing environment.   

## Want something more formal? ##
1. Use Apple Professional Services
2. Use VMware Professional Services
3. Review the [Reference Architecture on VMware TechZone](https://techzone.vmware.com/resource/workspace-one-and-horizon-reference-architecture#executive-summary)


## Table of Contents ##

- [Pre-Requisites to macOS Management](#pre-requisites-to-macos-management)
  - [Apple Push Notification Service (APNS)](#1-apple-push-notification-service-apns)
  - [AirWatch Cloud Messaging (AWCM)](#2-airwatch-cloud-messaging-awcm)
  - [Identity Connectors](#3-identity-connectors)
  - [Hub Services](#4-hub-services)
  - [(Optional) Workspace ONE Access](#5-optional-workspace-one-access)
  - [Apple Business Manager Automated Device Enrollment](#6-apple-business-or-school-manager-automated-device-enrollment)
  - [Apple Business Manager Volume-Purchased Apps](#7-apple-business-or-school-manager-volume-purchased-applications)
- [Setting up Configuration Management (Profile Payloads)](#setting-up-configuration-management-profile-payloads)
- [Setting up 3rd-Party Non-Store Applications](#setting-up-3rd-party-non-store-applications)
  - [Add the App to Workspace ONE](#add-the-app-to-workspace-one-uem)


## Pre-Requisites to macOS Management ##

### 1. Apple Push Notification Service (APNS) ###
APNS provides notifications to the macOS mdmclient (user and device) instructing it to check-in for commands. If you’re already managing iOS devices, this may already be completed.

1. In Workspace ONE UEM, navigate to *Devices > Devices Settings > Apple > APNs for MDM*
2. Select *Override > Generate New Certificate*
3. Download `MDM_APNsRequest.plist`
4. Go to Apple’s Website linked in the UEM Console & Authenticate
5. Click *Create a Certificate* and  Accept TOU
6. Upload the MDM plist and download the PEM
7. Upload PEM in Workspace ONE & Save

#### Relevant Documentation: ####
* [APNS (Apple Push Notification Service) Documentation (VMware)](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/9.6/vmware-airwatch-guides-96/GUID-AW96-DevicesUsers_Apple_APN.html)
* [Generating & Renewing APNS certificates (VMware)](https://support.air-watch.com/articles/115001662728)

> APNS required for macOS MDM Manageability


### 2. AirWatch Cloud Messaging (AWCM) ###
AWCM provides notifications to the VMware Intelligent Hub for macOS, allowing value-add functionality in the Hub to occur in real-time.  

> NOTE:  This setup is already done if SaaS-hosted!  

1. Ensure you installed AWCM from the downloaded Workspace ONE UEM installer.
2. Navigate to *Settings > System > Advanced > Secure Channel Certificate*
3. Download and Install **AWCM Secure Channel Certificate Installer** on AWCM Servers

#### Relevant Documentation:  ####
* [VMware AirWatch Cloud Messaging Overview](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/1907/AirWatch_Cloud_Messaging/GUID-AWT-AWCM-INTRODUCTION.html)
* [Secure Channel Certificate](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/9.6/vmware-airwatch-guides-96/GUID-AW96-ACCEnablingAWCM.html?hWord=N4IghgNiBcIM4FMDGBXATggBEgFmAdvghNgmgC4CWAZpUmOQiAL5A)

### 3. Identity Connectors ###
If not already done, you'll need to set up the AirWatch Cloud Connector (ACC) and/or the VMware Identity Manager Connector.  This is what provides connectivity to your LDAP/Active Directory services in order to enumerate/validate users when they attempt to enroll.  Connectors do not require inbound network connectivity, so they can be placed inside your network making only outbound calls to Workspace ONE UEM (ACC) or Workspace ONE Access (IDM Connector).

> **NOTE:** In cases where you're simply adding macOS as another platform into an already configured Workspace ONE deployment, these connectors may already have been installed and configured.  You do not need to set this up again if it is already in place for the specific organization group where you'll be enrolling macOS.

#### AirWatch Cloud Connector ####

> **NOTE:** The ACC is dependent upon AWCM to support secured messaging between Workspace ONE UEM and the ACC.

1. In Workspace ONE UEM, browse to *Groups & Settings > All Settings > System > Enterprise Integration > Cloud Connector*
2. Enable the AirWatch Cloud Connector and click **Download AirWatch Cloud Connector Installer**
3. Type and Verify a password to be used to secure the certificate included in the installer file and click **Download**
4. Install the ACC on one or more servers in your environment.
5. In Workspace ONE UEM, browse to *Groups & Settings > All Settings > System > Enterprise Integration > Directory Services*
6. Complete the wizard to enter information about your directory services, users, and groups.

#### (Optional) VMware Identity Manager Connector ####
The VMware Identity Manager Connector is optional and only required if you plan to fully configure VMware Workspace ONE Access (previously Identity Manager) to enable the Unified App Catalog (native/mobile, SaaS, and Virtual Apps), Notifications, and/or People integration for your macOS deployment.

1. Generate an activation code in the VMware Identity Manager console.
2. Download and run the VMware Identity Manager Connector Installer on a Windows server that meets all the requirements
3. Run the Connector Setup Wizard to activate the connector and set passwords
4. Configure proxy settings for the connector, if required.
5. When ready to enable the Hub Services requiring Workspace ONE Access, you must migrate the directory synchronization from Workspace ONE UEM to Workspace ONE Access (using the steps outlined in the relevant documentation linked below).
6. In Workspace ONE UEM, switch the Sourch of Authentication to Workspace ONE Access by navigating to *Groups & Settings > All Settings > Devices & Users > General > Enrollment* and on the *Authentication* tab you must choose **VMware Identity Manager** as the *Source of Authentication for Intelligent Hub*



#### Relevant Documentation: ####
* [VMware AirWatch Cloud Connector Installation Process](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/1907/AirWatch_Cloud_Connector/GUID-AWT-INSTALL-SUPERTASK.html)
* [Directory Services Settings Page Documentation](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/1907/System_Settings_On_Prem/GUID-AWT-SYSTEM-EI-DS.html?hWord=N4IghgNiBcICYEsBOBTAxgFwPZIJ4AIBnFJANwTRUPwQDsMUBzJMDBLWkAXyA)
* [VMware Identity Manager Cloud Deployment (With Windows Connector)](https://docs.vmware.com/en/VMware-Identity-Manager/services/vidm-cloud-deployment-winconnector/GUID-AE1397BA-21D6-4B08-BCD3-F870A07C3DEC.html)
* [About the VMware Identity Manager Connector](https://docs.vmware.com/en/VMware-Identity-Manager/services/identitymanager-connector-win/GUID-F3FD79B6-5F9F-4330-95F3-AF163A5D19C4.html)
* [Directory Migration from ACC to the VMware Identity Manager Connector](https://docs.vmware.com/en/VMware-Identity-Manager/services/identitymanager-connector-win/GUID-EE38DC37-959E-4CFB-A05A-3FBA55B95D23.html)
 


### 4. Hub Services ###
Hub Services are a distinct set of services co-located with, but separate from Workspace ONE Access (previously "Identity Manager").  Intelligent Hub requires UEM, but functionality is extended by Hub Services and/or Workspace ONE Access.  When combined with Workspace ONE Access integration, Hub Services enable the full digital experience (Unified Catalog, People, Notifications, etc) in the Intelligent Hub app.

> **NOTE:** Hub Services and Workspace ONE Access are co-located together in a cloud tenant, but a full Workspace ONE Access setup is not required to support Hub Services! 

#### Enable Hub Services Integration ####

1. In Workspace ONE UEM, navigate to *Getting Started > Workspace ONE > Workspace ONE Intelligent Hub*
2. Enter the Workspace ONE Access tenant URL and Administrator username/password.  (Optionally, you can *Request Cloud Tenant* if you do not have a Workspace ONE Access tenant provisioned to your organization.)
3. Click **Test Connection** and validate the test connection succeeds.   Click **Save**.
4. Access the *Workspace ONE Hub Services* console from the nine-square launchpad menu in the top-right corner or by navigating to *Groups & Settings > Configurations > Intelligent Hub* and clicking **Launch**.

#### Enable Hub Services Branding ####

1. From within Workspace ONE Hub Services, click the **Branding** Tab
2. Modify the branding settings as appropriate for your organization (Logo, Favicon, Colors and Text).
3. Click **Save**

#### Customize Intelligent Hub Services ####

1. From within Workspace ONE Hub Services, click the **Customization** Tab
2. Click the slider to enable the Custom (Home) tab and App Ratings.  Customize the Label/URL/Location for the Home tab.
3. Click the slider to enable People (the in-Hub directory/org chart) if desired.
4. Modify the App Catalog display by adding/removing/rearranging catalog sections.
5. Click **Save**
> NOTE: Only the Label value "Home" is localized.  If you enter any other word(s) for the label, the words will not be localized into other languages.

> NOTE: People functionality will not be shown in the Intelligent Hub application until Workspace ONE Access integration is configured appropriately.

#### Enable the Hub Catalog ####
For legacy compatibility, Workspace ONE UEM does not automatically enable the in-app catalog.   Admins must enable this functionality when they are ready to begin using it.

1. In Workspace ONE UEM, navigate to *Groups & Settings > Configurations > Intelligent Hub* 
2. Click **Configure* in the *Catalog Settings* box.
3. With the *Publishing* tab selected, enable *Intelligent Hub Catalog (macOS)* and disable *Legacy Catalog (macOS)*.
4. Click **Save**


### 5. (Optional) Workspace ONE Access ###
Workspace ONE Access enables SSO and Conditional Access for devices enrolled in Workspace ONE UEM.



### 6. Apple Business (or School) Manager Automated Device Enrollment ###
Admins should leverage Apple Business Manager (or Apple School Manager) to enable out-of-box automated enrollment.  

#### Relevant Documentation: ####
1. [ON-PREM:  Important Network Changes for Apple Fall Release 2019](https://techzone.vmware.com/blog/important-networking-changes-apple-fall-release)


### 7. Apple Business (or School) Manager Volume-Purchased Applications ###
Application delivery from the App Store (via Custom or Volume-Purchased Apps) is the "way forward" (per WWDC 2019) for app delivery on macOS.  VMware Workspace ONE UEM manages licenses and assignments through an integration with Apple Business (or School) Manager Locations.  To facilitate this integration, you must download a file from Apple Business

## Setting Up Configuration Management (Profile Payloads)


## Setting Up 3rd-Party Non-Store Applications ##
Use the following procedure to deliver Non-App Store applications to macOS.  Examples of software delivered in this method include Web Browsers (FireFox and/or Chrome), Virtual App Delivery Agents (Horizon or Citrix clients), and Tools/Utilities.

### Add the App to Workspace ONE UEM ###

1. In Workspace ONE UEM, Navigate to *Apps & Books > List View > Internal Apps*
2. Click **Add App** 
3. Upload dmg/pkg, metadata plist, icon, and configure relevant information
4. Click **Save & Assign**
5. Choose assignment groups, Blocking Apps, and Catalog/Desired State Behavior.



