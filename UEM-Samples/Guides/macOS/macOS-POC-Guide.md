# macOS Proof-of-Concept Guide

As organizations are embracing employee choice or embarking on their own [“Digital Transformation,”](https://techzone.vmware.com/blog/i-talked-160-customers-past-year-about-their-euc-plans-heres-what-i-learned) one thing became clear:  there’s a number of “accidental macOS admins.”  This guide aims to help anyone new to the macOS Platform (iOS/Android admins, traditional Windows admins, or newbies to PCLM/MDM/EMM/UEM) and focuses on enabling a user-driven, out-of-box enrollment flow using integrations with Apple Business Manager (or Apple School Manager).

>As always, contributions from the community are welcome, so if you find something missed (or have something to share) as you go through this guide, send us a pull request!  Much of the content in this guide was covered at VMworld 2019 in the UEM2099BU session:   [STREAM](https://www.vmworld.com/en/video-library/video-landing.html?sessionid=1561412646607001QngR&region=EU)

## THE TYPICAL "DON'T DO THIS IN YOUR PRODUCTION ENVIRONMENT" WARNING

This is general guidance to help you self-configure a macOS Proof-of-Concept in a lab or non-production/non-critical environment.  This guide is not actively maintained by VMware employees, and the documented procedures may change or become invalidated over time.

**DO NOT DO THIS IN YOUR PRODUCTION ENVIRONMENT!**

> There.. we said it.  Use your testing environment, a TestDrive Sandbox, or a self-hosted testing environment.

## Formal Recommendations on macOS Proof-of-Concepts

1. Use VMware Professional Services
1. Use Apple Professional Services
1. Review the [Reference Architecture on VMware TechZone](https://techzone.vmware.com/resource/workspace-one-and-horizon-reference-architecture#executive-summary)

---
---

## Table of Contents - Zero to ONE

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
- [Setting up Initial Notification for Intelligent Hub](#setting-up-initial-notification-for-intelligent-hub)

---
---

## Pre-Requisites to macOS Management

---

### 1. Apple Push Notification Service (APNS)

`If you’re already managing iOS devices, these steps may already be completed.`

APNS provides notifications to the macOS mdmclient (user and device) instructing it to check-in for commands. 

1. In Workspace ONE UEM, navigate to *Groups & Settings > Configurations > APNs for MDM*
1. Select *Generate New Certificate*.
1. Download `MDM_APNsRequest.plist`
1. Go to Apple’s Website linked in the UEM Console & Authenticate
1. Click *Create a Certificate* and  Accept TOU
1. Upload the MDM plist and download the PEM
1. Upload PEM in Workspace ONE & Save

> **NOTE:** The Apple ID used to generate APNS certificates should *ONLY* be used for this purpose. It is recommended to create an Apple ID using an email address that is a shared mailbox or group alias.  Apple will send APNS expiry warnings to this email address, and failure to renew the APNS certificate may lead to a production outage requiring re-enrollment.

**Relevant Documentation:**

- [APNS (Apple Push Notification Service) Documentation (VMware)](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/UEM_ConsoleBasics/GUID-AWT-APNSCERTS.html)
- [How to renew an Apple Push Notification (APNS) certificate (VMware)](https://kb.vmware.com/s/article/2960965?lang=en_US)
- [Use Apple Products on Enterprise Networks](https://support.apple.com/en-us/HT210060)

> **APNS is required for macOS Manageability with Workspace ONE**

---

### 2. AirWatch Cloud Messaging (AWCM)

`If you’re already managing Android or Rugged devices, these steps may already be completed.`

AWCM provides notifications to the VMware Intelligent Hub for macOS, allowing value-add functionality in the Hub to occur in real-time.  

> NOTE:  This setup is already done if SaaS-hosted.  You will not see the Secure Channel screen with the role assigned to administrators in SaaS-hosted environments.

1. Ensure you installed AWCM from the downloaded Workspace ONE UEM installer.
1. Navigate to *Settings > System > Advanced > Secure Channel Certificate*
1. Download and Install **AWCM Secure Channel Certificate Installer** on AWCM Servers

**Relevant Documentation**

- [VMware AirWatch Cloud Messaging Overview](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/AirWatch_Cloud_Messaging/GUID-AWT-AWCM-INTRODUCTION.html)
- [Secure Channel Certificate](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/AirWatch_Cloud_Messaging/GUID-AWT-ACCENABLINGAWCM.html)

---

### 3. Identity Connectors

`If you’re already managing other platforms, these steps may already be completed.`

If not already done, you'll need to set up the AirWatch Cloud Connector (ACC) and/or the Workspace ONE Access Connector.  This is what provides connectivity to your LDAP/Active Directory services in order to enumerate/validate users when they attempt to enroll.  Connectors do not require inbound network connectivity, so they can be placed inside your network making only outbound calls to Workspace ONE UEM (ACC) or Workspace ONE Access Connector.

> **NOTE:** In cases where you're simply adding macOS as another platform into an already configured Workspace ONE deployment, these connectors may already have been installed and configured.  You do not need to set this up again if it is already in place for the specific organization group where you'll be enrolling macOS.

#### AirWatch Cloud Connector

> **NOTE:** The ACC is dependent upon AWCM to support secured messaging between Workspace ONE UEM and the ACC.

1. In Workspace ONE UEM, browse to *Groups & Settings > All Settings > System > Enterprise Integration > Cloud Connector*
1. Enable the AirWatch Cloud Connector and click **Download AirWatch Cloud Connector Installer**
1. Type and Verify a password to be used to secure the certificate included in the installer file and click **Download**
1. Install the ACC on one or more servers in your environment.
1. In Workspace ONE UEM, browse to *Groups & Settings > All Settings > System > Enterprise Integration > Directory Services*
1. Complete the wizard to enter information about your directory services, users, and groups.

#### (Optional) Workspace ONE Access Connector

The Workspace ONE Access Connector is optional and only required if you plan to fully configure VMware Workspace ONE Access (previously Identity Manager) to enable the Unified App Catalog (native/mobile, SaaS, and Virtual Apps), Notifications, and/or People integration for your macOS deployment.

> **NOTE:** Do not install/use the 20.01 connector if you plan to integrate Horizon, Horizon Cloud, or Citrix applications and desktops.  If you plan to use virtual apps, you must use the 19.03 version.

1. In the Workspace ONE Access console, navigate to **Identity & Access Management > Setup > Connectors**
1. Click **New** and select **Workspace ONE Access Connector 20.01* (unlesss you have a need to use a Legacy connector)
1. Review the information and click **Proceed anyway**
1. In the wizard, click the *Go To MyVMware.com* link and download the Connector.  
1. After you have installed the connector on a server, return to the Access console and verify the connector is showing installed.

> When ready to enable the Hub Services requiring Workspace ONE Access, you must migrate the source of authentication from Workspace ONE UEM to Workspace ONE Access (using the steps outlined in the relevant documentation linked below).  In Workspace ONE UEM, switch the Source of Authentication to Workspace ONE Access by navigating to *Groups & Settings > All Settings > Devices & Users > General > Enrollment* and on the *Authentication* tab you must choose **Workspace ONE Access** as the *Source of Authentication for Intelligent Hub*

**Relevant Documentation:**

- [VMware AirWatch Cloud Connector Documentation](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/AirWatch_Cloud_Connector/GUID-AWT-ACC-INTRODUCTION.html)
- [Directory Services Settings Page Documentation](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/System_Settings_On_Prem/GUID-AWT-SYSTEM-EI-DS.html?hWord=N4IghgNiBcICYEsBOBTAxgFwPZIJ4AIBnFJANwTRUKJQwwQDsBzQkAXyA)
- [Workspace ONE Access 20.01 Overview and Connector Architecture](https://techzone.vmware.com/vmware?share=video1830)
- [Workspace ONE Access Components - Feature Walkthrough](https://techzone.vmware.com/vmware?share=video1909)
- [Workspace ONE Access Connector Overview - Feature Walkthrough](https://techzone.vmware.com/vmware?share=video2272)
- [Directory Migration from ACC to the Workspace ONE Access Connector](https://docs.vmware.com/en/VMware-Workspace-ONE-Access/3.3/identitymanager-connector-win/GUID-EE38DC37-959E-4CFB-A05A-3FBA55B95D23.html?hWord=N4IghgNiBcILYEsDmAnMAXBB7AdgAgDMUs48BBAYQr3S3IGN6BTAZxZAF8g)
- [Installing the Workspace ONE Access Connector](https://docs.vmware.com/en/VMware-Workspace-ONE-Access/services/ws1_access_connector_install/GUID-62084B58-850F-4688-BECF-C8EA594C688D.html?hWord=N4IghgNiBcIGoFkDuYBOBTABGAxj9AzgZjgPYB256OALqapgejQK4AOIAvkA)

---

### 4. Hub Services

Hub Services are a distinct set of services co-located with, but separate from Workspace ONE Access (previously "Identity Manager").  Intelligent Hub requires UEM, but functionality is extended by Hub Services and/or Workspace ONE Access.  When combined with Workspace ONE Access integration, Hub Services enable the full digital experience (Unified Catalog, People, Notifications, Mobile Flows, etc) in the Intelligent Hub app.

> **NOTE:** Hub Services and Workspace ONE Access are co-located together in a cloud tenant, but a full Workspace ONE Access setup is not required to support Hub Services!

#### Enable Hub Services Integration

`If you’re already managing iOS devices, these steps may already be completed.`

1. In Workspace ONE UEM, navigate to *Getting Started > Workspace ONE > Workspace ONE Intelligent Hub*
1. Enter the Workspace ONE Access tenant URL and Administrator username/password.  (Optionally, you can *Request Cloud Tenant* if you do not have a Workspace ONE Access tenant provisioned to your organization.)
1. Click **Test Connection** and validate the test connection succeeds.   Click **Save**.
1. Access the *Workspace ONE Hub Services* console from the nine-square launchpad menu in the top-right corner or by navigating to *Groups & Settings > Configurations > Intelligent Hub* and clicking **Launch**.

#### Enable Hub Services Branding

`If you’re already managing iOS devices, these steps may already be completed.`

1. From within Workspace ONE Hub Services, click the **Branding** Tab
1. Modify the branding settings as appropriate for your organization (Logo, Favicon, Colors and Text).
1. Click **Save**

#### Customize Intelligent Hub Services

`If you’re already managing iOS devices, these steps may already be completed.`

1. From within Workspace ONE Hub Services, click the **Customization** Tab
1. Click the slider to enable the Custom (Home) tab and App Ratings.  Customize the Label/URL/Location for the Home tab.
1. Click the slider to enable People (the in-Hub directory/org chart) if desired.
1. Modify the App Catalog display by adding/removing/rearranging catalog sections.
1. Click **Save**

> NOTE: Only the Label value "Home" is localized.  If you enter any other word(s) for the label, the words will not be localized into other languages.

#### Notes about People Search

People functionality will not be shown in the Intelligent Hub application until Workspace ONE Access integration is configured appropriately.  People leverages the `manager` attribute to display org heirarchy (be sure to map this to `managerDN`), and the thumbnailPhoto attribute to display employee photos.  

For the purposes of a demo, the following script can be useful for populating photos into the thumbnailPhoto attribute:

```powershell
# credit to http://woshub.com/how-to-import-user-photo-to-active-directory-using-powershell/
Import-Module ActiveDirectory
Import-Csv C:\PS\import.csv | %{Set-ADUser -Identity $_.AD_username -Replace @{thumbnailPhoto=([byte[]](Get-Content $_.Photo -Encoding byte))}}
```

It leverages a CSV formatted as follows:

```CSV
AD_username,Photo
asmith,C:\PS\asmith.jpg
klinton@adatum.com,C:\PS\klinton.jpg
jkuznetsov,C:\PS\jkuznetso.png
```

#### Enable the Hub Catalog

For legacy compatibility, Workspace ONE UEM does not automatically enable the in-app catalog.   Admins must enable this functionality when they are ready to begin using it.  

> In cases where you're already using Intelligent Hub for the app catalog on iOS, you may still need to validate the Hub catalog is enabled for macOS.  

1. In Workspace ONE UEM, navigate to *Groups & Settings > Configurations > Intelligent Hub* 
1. Click **Configure* in the *Catalog Settings* box.
1. With the *Publishing* tab selected, enable *Intelligent Hub Catalog (macOS)* and disable *Legacy Catalog (macOS)*.
1. Click **Save**

**Relevant Documentation:**

- [Administering Hub Services with Workspace ONE UEM and Workspace ONE Access](https://docs.vmware.com/en/VMware-Workspace-ONE/services/intelligent-hub_IDM/GUID-7ADD4A02-DE07-4BBA-841B-40AFFDD19863.html)
- [How to Activate Hub Services](https://docs.vmware.com/en/VMware-Workspace-ONE/services/intelligent-hub_IDM/GUID-19581E5A-BC8A-465F-ABFF-C243D69393CB.html)
- [Using Hub Services without Enabling Workspace ONE Access (Workspace ONE Access)](https://docs.vmware.com/en/VMware-Workspace-ONE/services/intelligent-hub_IDM/GUID-BEFA3A94-357A-4B9C-AEC6-5B62D2BF3AEE.html)
- [Hub Services when Workspace ONE Access is Integrated](https://docs.vmware.com/en/VMware-Workspace-ONE/services/intelligent-hub_IDM/GUID-826D5409-98C6-4A37-B4A9-B3DFD244AAE8.html)

---

### 5. (Optional) Workspace ONE Access

Workspace ONE Access enables SSO and Conditional Access for devices enrolled in Workspace ONE UEM.  Since the breadth and depth of a Workspace ONE Acceess integration varies quite a bit, you'll most likely get the most value by reading the documents available for common scenarios.  Be sure to check out the Activity Path on TechZone as it contains hands-on labs where you can safely walk through some of these configuration scenarios before you attempt them in your own testing environment.

From the perspective of a POC or lightweight demo, you can possibly attempt this by federating with a [small instance of Microsoft 365](https://developer.microsoft.com/en-us/microsoft-365/dev-program).  Some guidance as to a typical demo setup:

1. Set up two Domain Controllers (prefer Windows Server 2016/2019) with a single domain/forest (you can use one to host the ACC and one to host the IDM Connector)
1. In the Workspace ONE Access console, set up User Attributes by navigating to *Identity & Access Management > Setup > User Attributes*.  Be sure to mark UserPrincipalName as required.  Add `objectGUID` and `mS-DS-ConsistencyGuid` as additional attributes.  Add any additional attributes you'd like exposed by "People" functionality (such as managerDN).
1. Set up the Identity Manager Connector by navigating to *Identity & Access Management > Setup > Connectors*.  Click **Add Connector**.
1. Set up the Directory by navigating to *Identity & Access Management > Directories*.  Click **Add Directory**.
1. Set up People Search by navigating to *Catalog (pull down) > Settings > People Search*.  Enable People Search and map attributes as appropriate.
1. Add the connector to the Built-In Identity Provider by navigating to *Identity & Access Management > Identity Providers*.  Click the **Built-In** provider and add the AD directory and connector.  Be sure to also select a connector to use and enable *Password (Cloud Deployment)* as a Connector Authentication Method.
1. Configure the Default Policy Set by navigating to *Identity & Access Management > Policies*.  Add the *Password (Cloud Deployment)* authentication option to enable login using credentials pulled from the Connector.

> **NOTE**:  Do not enable "thumbnailPhoto" when configuring the additional sync attributes.  These will be automatically mapped when People Search is enabled.

#### Notes Regarding Office365 Demo Setups

Just a few notes to help you find your way around the Office365 Integration if you're not overly familiar with Identity/Federation and the Microsoft tools:

> Documentation can be found at [Connect to Microsoft 365 With PowerShell](https://docs.microsoft.com/en-us/microsoft-365/enterprise/connect-to-microsoft-365-powershell?view=o365-worldwide).

1. Install the [AzureADPreview Powershell Cmdlets](https://social.technet.microsoft.com/wiki/contents/articles/28552.microsoft-azure-active-directory-powershell-module-version-release-history.aspx#A) -- `PS>   Install-Module -Name MSOnline`
1. Download & Install the [MS Online Services Sign-In Assistant](https://www.microsoft.com/en-us/download/details.aspx?id=41950)
1. Download & Install [Azure AD Connect](https://docs.microsoft.com/en-us/azure/active-directory/hybrid/reference-connect-version-history)
1. Configure Azure AD Connect --> select either Password Hash Synchronization or Do Not Configure.
1. When sync completes, log into the O365 Admin portal and ensure your demo "users" are licensed for Office E1 or E3.  (E3 allows you to explore graph API integration for iOS MAM controls)
1. Use Powershell to Update the domain from Managed to Federated:

```Powershell
## Set the Domain to Federated
Set-MSolDomainAuthentication -DomainName <Domain Name To Be Federated> -Authentication Federated -IssuerURI "<tenant IDM Url - e.g. yourtenant.workspaceoneair.com>" -FederationBrandName "<Domain Name to be Federated>" -PassiveLogOnURI "https://<Tenant IDM URL>/SAAS/API/1.0/POST/sso" -ActiveLogOnURI "https://<Tenant IDM URL>/SAAS/auth/wsfed/active/logon" -LogOffURI "https://login.microsoftonline.com/logout.srf" -MetadataExchangeURI "https://<Tenant IDM URL>/SAAS/auth/wsfed/services/mex" -SigningCertificate <Signing Cert downloaded from Catalog > Settings > SAML MetaData>
```

> Note - The above PowerShell uses the older v1 Azure AD cmdlets.   If you happen to know how to do this with the V2 preview cmdlets, please send us a pull request with an update!

#### Notes Regarding SSO via Workspace ONE Access

Workspace ONE Access can significantly reduce the amount of username/password prompts your users endure by leveraging Certificate Authentication.   Workspace ONE UEM includes built-in CA functionality that Workspace ONE Access can leverage to generate and validate user-based certificates on the fly. To enable this functionality, you'll need to do the following:

1. In the UEM Console, navigate to *Groups & Settings > All Settings > System > Enterprise Integration > Workspace ONE Access > Configuration
1. Enable certificate provisioning and export the issuer certificate.
1. In the Workspace ONE Access console, navigate to *Identity & Access Management > Authentication Methods* and edit the *Certificate (Cloud Deployment)* option.
1. **Enable** the certificate adapter.  For *Root and Intermediate CA certificates*, click **Select File** and upload the Issuer Certificate you downloaded from the UEM console.   Change the User Identifier Search Order to **upn | email | subject** and click **Save**.
1. Navigate to *Identity & Access Management > Identity Providers > Built-In*.   Associate the **Certificate (Cloud Deployment)** authentication method and click **Save**.
1. Navigate to *Identity & Access Management > Policies* and click **Edit Default Policy**.  
1. Click **Next** and then modify both rules (Web Browser and Workspace ONE App) to say the following (remember, these are rules for a small scale POC):

    ```CSV
    Authenticate Using...
    Certifcate (Cloud Deployment)
    If preceding method fails:   Password (Cloud Deployment)
    If preceding method fails:   Password
    If preceding method fails:   Password (Local Directory)
    ```

1. Click **Save** when completed.
1. In the UEM Console, click *Add > Profile > macOS > User.   Configure the General payload settings.

    > For help setting up SSO profiles, refer to the [TechZone Article about Identity Preferences](https://techzone.vmware.com/blog/managing-identity-preferences-streamline-single-sign-macos-revisited).  You basically need to create a profile with 2 parts:  the SCEP profile pointing to the UEM-Access CA integration (for the user's identity cert), and either an Identity Preference configuration in the SCEP payload to set the preference for Safari and WebKit, or a Custom Settings payload that sets the app-specific preference to auto-select the identity certificate.

1. Click the *SCEP* payload and click **Configure**.   Choose *AirWatch Certificate Authority* for the *Source* and *Authority* fields. Choose *Certificate Authority* and ensure "allow access" is checked.
1. Modify the *Identity Preferences* in the SCEP payload, or add and configure the *Custom Settings* payload.  Complete the payload settings per the TechZone article.

**Relevant Documentation:**

- [Attributes that can be Enabled for People Search](https://docs.vmware.com/en/VMware-Identity-Manager/3.3/idm-administrator/GUID-F965647F-92BC-4317-92F6-D31D086EB679.html?hWord=N4IghgNiBcIC4AsCuBbARgOzASwgBwQHs5CQBfIA)
- [Workspace ONE Access (previously Identity Manager) Activity Path](https://techzone.vmware.com/becoming-identity-manager-hero)
- [Workspace ONE Access Integration with Office 365](https://www.vmware.com/pdf/vidm-office365-saml.pdf)
- [Workspace ONE Access 19.03: Configuring Certificate Authentication](https://www.youtube.com/watch?v=s4EILnnP98I)
- [Managing Identity Preferences to Streamline Single Sign-On for macOS](https://techzone.vmware.com/blog/managing-identity-preferences-streamline-single-sign-macos-revisited)

---

### 6. Apple Business (or School) Manager Automated Device Enrollment

Admins should leverage Apple Business Manager (or Apple School Manager) to enable out-of-box automated enrollment.  

1. In Workspace ONE UEM, navigate to *Groups & Settings > Configurations > Apple Device Enrollment Program*
1. Click **Configure**
1. Click **MDM_DEP_PublicKey.pem** to download it.
1. Click the link to **[Apple Business Manager](https://business.apple.com)**
1. Log-in to Apple Business Manager.
1. Click *Settings > Device Management Settings > Add MDM Server*
1. Enter a Name for the MDM Server, then click **Choose File**
1. Browse for and select the **MDM_DEP_PublicKey.pem** file then click **Save**
1. Click *Settings > {Your New MDM Server Name}* and click **Download Token**
1. In Workspace ONE UEM, click **Upload**
1. Browse for and select the token downloaded from Apple Business Manager and click **Next** to begin building your first Automated Device Enrollment (previously Device Enrollment Program) profile.
1. Enter relevant information about your organization and choose the options you want to enable.  See below for recommended settings.   Click **Next**
1. Choose which options in the Setup Assistant you would like the end-user to Skip.  Click **Next**
1. Choose whether to make the profile the default and assign to newly synced devices.  Click **Finish**

> **NOTE:** If you attempt to save the DEP profile and get an error, you most likely took too long in the DEP setup wizard.      If this is the case, you must start the process over (downloading *NEW* tokens).   You need not worry about analyzing each setting for your initial profile.  You can easily modify it after-the-fact under *Groups & Settings > Configurations > Apple Device Enrollment Program*

#### Notes on Recommended DEP Profile Settings

- **Custom Enrollment**  This changes the authentication flow in Automated Enrollments to use a web view rather than the normal username/password.   This web view can display a login page from a SAML Provider or Workspace ONE Access, allowing you to do customize the enrollment experience (including terms of use, and multifactor authentication).
- **Require MDM Enrollment** — This setting enforces enrollment should the device be wipe/reinstalled.
- **Lock MDM Profile** — This setting will help ensure your devices do not become unmanaged by the end user (e.g. the user cannot remove the MDM profile).
- **Await Configuration** — This setting holds the user in the setup assistant for a few moments longer, allowing more time for MDM to deliver configuration profiles *before* the User sees the Login Window.
- **Primary User Account Customization:**
  - **Account Type** - Choose what access rights to give the local macOS user account created by the user in SetupAssistant.
  - **AutoFill** - You can autofill the user account information in the Setup Assistant using Lookup Values.
  - **Allow Editing** - By disabling this, the user cannot change the username or firstname/lastname combination.  This helps enforce standardized local macOS accounts
- **Admin Account Creation Customization:**
  - **Create New Admin Account** — This allows IT to create a hidden admin account for use in accessing the device if the user’s account becomes locked out or corrupt.
  - **Unique Random Password** - This randomizes the Admin Account password and escrows the password in Workspace ONE UEM.  If the password is later accessed or viewed from Workspace ONE, Workspace ONE will set a new randomized password for the admin account and update the password stored in escrow.

**Relevant Documentation:**

- [ON-PREM:  Important Network Changes for Apple Fall Release 2019](https://techzone.vmware.com/blog/important-networking-changes-apple-fall-release)
- [Use Apple Products on Enterprise Networks](https://support.apple.com/en-us/HT210060)

---

### 7. Apple Business (or School) Manager Volume-Purchased Applications

Application delivery from the App Store (via Custom or Volume-Purchased Apps) is the "way forward" (per WWDC 2019) for app delivery on macOS.  VMware Workspace ONE UEM manages licenses and assignments through an integration with Apple Business (or School) Manager Locations.  To facilitate this integration, you must download a file from Apple Business Manager (known as the "location token") and upload it to VMware.

In Workspace ONE UEM, perform the following:

1. Navigate to  *Groups & Settings > Configurations > VPP Managed Distribution*
1. Click **Upload**
1. Browse and select the location token downloaded from Apple Business Manager (from *Settings > Apps & Books*)
1. Enter a name for the token, **Uncheck** Automatically send invites and click **Save**
1. Navigate to *Apps & Books > Applications > Native > Purchased*
1. Click **Sync Assets**
1. For each VPP app that has been synced in, configure the following items:

    - **Categories:**   This helps Hub Services provide app categorization in the Intelligent Hub
    - **Licenses to Allocate:**   If the app is free, we recommend purchasing more apps than required to allow for growth without needing to constantly manage license numbers.
    - **Deployment Type:**   We recommend limiting the number of apps you initially load on the device.   Let the user self-service choose the apps they want on their device.  You can automatically deploy common apps such as Microsoft Outlook and the VMware Tunnel app.

> **NOTE:** Newer versions of Workspace ONE UEM allow you to bulk-select applications to enable them for device-based assignment.  Choosing device-based assignment eliminates the need for the end-user to have an Apple ID.

#### Notes about Apple Caching Services

If you don't already have Apple macOS Caching Services deployed in your environment, it is highly recommended by VMware and Apple.  Caching Services allows you to reduce WAN bandwidth consumption by allowing downloads from the App Store (apps, os updates, etc) to be cached locally.  This allows local reuse by other devices on your network.  The Apple App Store CDN dynamically redirects clients to internal caches to obtain content.

In a large/complex network, plan your caching services configurations accordingly (tree, hub/spoke, etc).   More detail can be found in Apple's documentation.

**Relevant Documentation:**

- [Use Apple Products on Enterprise Networks](https://support.apple.com/en-us/HT210060)
- [About Content Caching on Mac](https://support.apple.com/guide/mac-help/about-content-caching-on-mac-mchl9388ba1b/mac)
- [Manage Content Caching on Mac](https://support.apple.com/guide/mac-help/manage-content-caching-on-mac-mchl3b6c3720/10.14/mac/10.14)
- [Content Types supported by content caching in macOS](https://support.apple.com/en-us/HT204675)
- [Set up content cache clients, peers, or parents on Mac](https://support.apple.com/guide/mac-help/set-content-cache-clients-peers-parents-mac-mchl9b56e1cf/10.14/mac/10.14)
- [Configure Advanced content caching settings on Mac](https://support.apple.com/guide/mac-help/configure-advanced-content-caching-settings-mchl91e7141a/10.14/mac/10.14)
- [View content caching logs and statistics on Mac](https://support.apple.com/guide/mac-help/view-content-caching-logs-statistics-mac-mchl0d8533cd/10.14/mac/10.14)
- [Enable Content Cache discovery across multiple public IP addresses on Mac](https://support.apple.com/guide/mac-help/enable-content-cache-discovery-multiple-mchld4ab5cdc/10.14/mac/10.14)

---
---

## Setting Up Configuration Management (Profile Payloads)

Workspace ONE UEM has the capability to manage both the device mdmclient and the user session's mdmclient. This basically allows admins to manage in two separate scopes:  root/system context and user context.   The following set of steps walks you through managing a basic set of security-related items for macOS.  Admins are encouraged to explore the feature set and determine which profile payloads are of value to their specific organization.

> Note:  Some profile payloads (such as *Custom Attributes*) are functions of the Workspace ONE Intelligent Hub and *not* the mdmclient.  In this case, you will not be able to test the feature unless you have the Workspace ONE Intelligent Hub installed.

### Login Window

1. In the UEM Console, click *Add > Profile > macOS > Device*
1. Complete the following profile items on the General Tab:
    - Name:  Login Window
    - Assignment:  assign to the OG or All Devices groups
1. Click on the **Login Windonw** payload and click **Configure**.
1. Select the *Options* tab.
    - Start Screen Saver
    - After 5 minutes
    - Module:  `/System/Library/Screen Savers/Flurry.saver`
1. Click **Save & Publish** > **Publish**

### Security & Privacy

1. Click *Add > Profile > macOS > Device*
1. Complete the following profile items on the General Tab:
    - Name:  Security
    - Assignment:  assign to the OG or All Devices groups
1. Click on the **Security & Privacy** payload and click **Configure**
    - OS Update Delay:  15 days
    - Mac App Store & ID Developers
    - Do Not Allow Override
    - Allow Watch/TouchID
    - Enabled Require Password after Screensaver
    - Grace Period "Immediately"
1. Click **Save & Publish** > **Publish**

### Firewall

1. In the UEM Console, click *Add > Profile > macOS > Device*
1. Complete the following profile items on the General Tab:
    - Name:  Firewall
    - Assignment:  assign to the OG or All Devices groups
1. Click on the **Firewall** payload and click **Configure**
    - Enable
    - Block All Incoming
    - Automatically Allow Signed
    - Enable Stealth Mode
1. Click **Save & Publish** > **Publish**

### FileVault

1. In the UEM Console, click *Add > Profile > macOS > Device*
1. Complete the following profile items on the General Tab:
    - Name:  FileVault
    - Assignment:  assign to the OG or All Devices groups
1. Click on the **Disk Encryption** payload and click **Configure**
    - ByPass Login 5 times
1. Click **Save & Publish** > **Publish**

### Software Update

1. Click *Add > Profile > macOS > Device*
1. Complete the following items on the General Tab:
    - Name: Software Update
    - Assignment:  assign to the OG or All Devices groups
1. Click on the **Software Update** Payload and click **Configure**
    - Install Automatically
    - All Updates
    - Notify User
    - Update Interval
    - Force Restart
1. Click **Save & Publish** > **Publish**

### Privacy Preferences

1. Click *Add > Profile > macOS > Device*
1. Complete the following profile items on the General tab:
    - Name:  Privacy Preferences
    - Assignment:  assign to the OG or All Devices groups
1. Click on the **Privacy Preferences** payload and click **Configure**
    - Add relevant [macOS Privacy Preferences Policy Control settings](https://github.com/vmware-samples/euc-samples/tree/master/macOS-Samples/Privacy%20Preferences%20Policy%20Control) per the apps you intend to deploy.
1. Click **Save & Publish** > **Publish**

**Relevant Documentation:**

- [macOS Mojave User Consent for Data Access Changes](https://techzone.vmware.com/blog/vmware-workspace-one-uem-apple-macos-mojave-user-consent-data-access)
- [macOS Privacy Preferences Policy Control Samples](https://github.com/vmware-samples/euc-samples/tree/master/macOS-Samples/Privacy%20Preferences%20Policy%20Control)
- [macOS Custom XML Samples](https://github.com/vmware-samples/euc-samples/tree/master/macOS-Samples/CustomXMLProfiles)
- [macOS Custom Attribute Samples](https://github.com/vmware-samples/euc-samples/tree/master/macOS-Samples/CustomAttributes)
- [Workspace ONE UEM Console Lookup Values](https://support.workspaceone.com/articles/115001663908)

---
---

## Setting Up 3rd-Party Non-Store Applications

Use the following procedure to deliver Non-App Store applications to macOS.  Examples of software delivered in this method include Web Browsers (FireFox and/or Chrome), Virtual App Delivery Agents (Horizon or Citrix clients), and Tools/Utilities.

### Process the App Installer with VMware Workspace ONE Admin Assistant (VWOAA) App

The [VWOAA app](https://getwsone.com/AdminAssistant/VMwareWorkspaceONEAdminAssistant.dmg) is basically a GUI wrapper for a tool that generates a metadata file used by the Workspace ONE Intelligent Hub to deploy non-store apps.

1. Open the VWOAA app and either browse for a DMG/PKG/MPKG file or drag-n-drop it on the UI.
1. VWOAA processes the file and outputs it to a folder in your `~\Documents` folder.
1. Click the magnifying glass to open to the location in Finder.

### Add the App to Workspace ONE UEM

1. In Workspace ONE UEM, Navigate to *Apps & Books > List View > Internal Apps*
1. Click **Add App** 
1. Upload dmg/pkg, metadata plist, icon, and configure relevant information (including categories)
1. Add a postinstall script to leverage hubcli ("Hub Command Line Interface") to generate notifications to the user when the install completes:

    ```bash
    /usr/local/bin/hubcli notify -t "BBEdit Installed"  -i "Workspace ONE has finished installing BBEdit" -a "Open BBEdit" -b "usr/bin/open /Applications/BBEdit.app" -c "Close"
    ```

1. Click **Save & Assign**
1. Choose assignment groups, Blocking Apps, and Catalog/Desired State Behavior.
1. Publish the application.

> **NOTE:** Run `/usr/local/bin/hubcli` in Terminal to view help and usage details.

---
---

## Setting Up Initial Notification for Intelligent Hub

While a number of customers have taken advantage of Bootstrap functionality introduced in UEM 9.2 for "onboarding splash screens," we've started to see an uptick in customers simplifying the onboarding process.   In these slimmed-down use cases, the focus has been shifted to employee experience and self-service.   Basically, the goal is to get the user to a minimally provisioned desktop as soon as possible.   In this scenario, very few apps are auto-deployed and instead the user is notified to start the VMware Intelligent Hub to explore the available app catalog and choose the apps they want installed.

In this scenario, an admin can accomplish this in one of two ways: the Products framework, or the Internal Apps framework.  Either one works, it's more a matter of preference to the admin.   In both cases, the auto-deployed package doesn't run until the user is logged-in to macOS.

### Use the Internal Apps Framework to Trigger HubCLI Notification

In this case, an admin can create a [payload-free package](https://techzone.vmware.com/distributing-scripts-macos-vmware-workspace-one-operational-tutorial#1037001) (containing just the script) to the device.  In this scenario, you can still leverage the same command for hubcli as was used for Option 1 (Products)  

**Relevant Documentation:**

* [Distributing Scripts as Internal Apps for macOS](https://techzone.vmware.com/distributing-scripts-macos-vmware-workspace-one-operational-tutorial#1037001)
