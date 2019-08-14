# macOS Proof-of-Concept Guide #
As organizations are embracing employee choice or embarking on their own [“Digital Transformation,”](https://techzone.vmware.com/blog/i-talked-160-customers-past-year-about-their-euc-plans-heres-what-i-learned) one thing became clear:  there’s a number of “accidental macOS admins.”  This guide aims to help anyone new to the macOS Platform (iOS/Android admins, traditional Windows admins, or newbies to PCLM/MDM/EMM/UEM) and focuses on enabling a user-driven, out-of-box enrollment flow using integrations with Apple Business Manager (or Apple School Manager).

>As always, contributions from the community are welcome, so if you find something missed (or have something to share) as you go through this guide, send us a pull request!

## Table of Contents ##

- [Pre-Requisites to macOS Management](#pre-requisites-to-macos-management)
  - [Apple Push Notification Service (APNS)](#1-apple-push-notification-service-apns)
  - [AirWatch Cloud Messaging (AWCM)](#2-airwatch-cloud-messaging-awcm)
  - [Hub Services](#3-hub-services)
  - [(Optional) Workspace ONE Access](#4-optional-workspace-one-access)
  - [Apple Business Manager Automated Device Enrollment](#5-apple-business-or-school-manager-automated-device-enrollment)
  - [Apple Business Manager Volume-Purchased Apps](#6-apple-business-or-school-manager-volume-purchased-applications)
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
1. [VMware AirWatch Cloud Messaging Overview](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/1907/AirWatch_Cloud_Messaging/GUID-AWT-AWCM-INTRODUCTION.html)
2. [Secure Channel Certificate](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/9.6/vmware-airwatch-guides-96/GUID-AW96-ACCEnablingAWCM.html?hWord=N4IghgNiBcIM4FMDGBXATggBEgFmAdvghNgmgC4CWAZpUmOQiAL5A)


### 3. Hub Services ###
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


### 4. (Optional) Workspace ONE Access ###
Workspace ONE Access enables SSO and Conditional Access for devices enrolled in Workspace ONE UEM.


### 5. Apple Business (or School) Manager Automated Device Enrollment ###
Admins should leverage Apple Business Manager (or Apple School Manager) to enable out-of-box automated enrollment.  

#### Relevant Documentation: ####
1. [ON-PREM:  Important Network Changes for Apple Fall Release 2019](https://techzone.vmware.com/blog/important-networking-changes-apple-fall-release)


### 6. Apple Business (or School) Manager Volume-Purchased Applications ###
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



