# macOS Proof-of-Concept Guide #
As organizations are embracing employee choice or embarking on their own [“Digital Transformation,”](https://techzone.vmware.com/blog/i-talked-160-customers-past-year-about-their-euc-plans-heres-what-i-learned) one thing became clear:  there’s a number of “accidental macOS admins.”  This guide aims to help anyone new to the macOS Platform (iOS/Android admins, traditional Windows admins, or newbies to PCLM/MDM/EMM/UEM) and focuses on enabling a user-driven, out-of-box enrollment flow using integrations with Apple Business Manager (or Apple School Manager).

>As always, contributions from the community are welcome, so if you find something missed (or have something to share) as you go through this guide, send us a pull request!



## THE TYPICAL "DON'T DO THIS IN YOUR PRODUCTION ENVIRONMENT" WARNING: ##
This is general guidance to help you self-configure a macOS Proof-of-Concept in a lab or non-production/non-critical environment.  This guide is not actively maintained by VMware employees, and the documented procedures may change or become invalidated over time.   

**DO NOT DO THIS IN YOUR PRODUCTION ENVIRONMENT!**

> There.. we said it.  Use your testing environment, a TestDrive Sandbox, or a self-hosted testing environment.   



## Want something more formal? ##
1. Use VMware Professional Services
2. Use Apple Professional Services
3. Review the [Reference Architecture on VMware TechZone](https://techzone.vmware.com/resource/workspace-one-and-horizon-reference-architecture#executive-summary)

**************************************************************************************************
**************************************************************************************************

## Table of Contents - Zero to ONE ##

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

**************************************************************************************************
**************************************************************************************************


## Pre-Requisites to macOS Management ##
**************************************************************************************************
### 1. Apple Push Notification Service (APNS) ###
`If you’re already managing iOS devices, these steps may already be completed.`

APNS provides notifications to the macOS mdmclient (user and device) instructing it to check-in for commands. 

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

**************************************************************************************************

### 2. AirWatch Cloud Messaging (AWCM) ###
`If you’re already managing Android or Rugged devices, these steps may already be completed.`

AWCM provides notifications to the VMware Intelligent Hub for macOS, allowing value-add functionality in the Hub to occur in real-time.  

> NOTE:  This setup is already done if SaaS-hosted!  

1. Ensure you installed AWCM from the downloaded Workspace ONE UEM installer.
2. Navigate to *Settings > System > Advanced > Secure Channel Certificate*
3. Download and Install **AWCM Secure Channel Certificate Installer** on AWCM Servers

#### Relevant Documentation:  ####
* [VMware AirWatch Cloud Messaging Overview](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/1907/AirWatch_Cloud_Messaging/GUID-AWT-AWCM-INTRODUCTION.html)
* [Secure Channel Certificate](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/9.6/vmware-airwatch-guides-96/GUID-AW96-ACCEnablingAWCM.html?hWord=N4IghgNiBcIM4FMDGBXATggBEgFmAdvghNgmgC4CWAZpUmOQiAL5A)

**************************************************************************************************

### 3. Identity Connectors ###
`If you’re already managing other platforms, these steps may already be completed.`

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

**************************************************************************************************

### 4. Hub Services ###
Hub Services are a distinct set of services co-located with, but separate from Workspace ONE Access (previously "Identity Manager").  Intelligent Hub requires UEM, but functionality is extended by Hub Services and/or Workspace ONE Access.  When combined with Workspace ONE Access integration, Hub Services enable the full digital experience (Unified Catalog, People, Notifications, etc) in the Intelligent Hub app.

> **NOTE:** Hub Services and Workspace ONE Access are co-located together in a cloud tenant, but a full Workspace ONE Access setup is not required to support Hub Services!

#### Enable Hub Services Integration ####

`If you’re already managing iOS devices, these steps may already be completed.`

1. In Workspace ONE UEM, navigate to *Getting Started > Workspace ONE > Workspace ONE Intelligent Hub*
2. Enter the Workspace ONE Access tenant URL and Administrator username/password.  (Optionally, you can *Request Cloud Tenant* if you do not have a Workspace ONE Access tenant provisioned to your organization.)
3. Click **Test Connection** and validate the test connection succeeds.   Click **Save**.
4. Access the *Workspace ONE Hub Services* console from the nine-square launchpad menu in the top-right corner or by navigating to *Groups & Settings > Configurations > Intelligent Hub* and clicking **Launch**.

#### Enable Hub Services Branding ####

`If you’re already managing iOS devices, these steps may already be completed.`

1. From within Workspace ONE Hub Services, click the **Branding** Tab
2. Modify the branding settings as appropriate for your organization (Logo, Favicon, Colors and Text).
3. Click **Save**

#### Customize Intelligent Hub Services ####

`If you’re already managing iOS devices, these steps may already be completed.`

1. From within Workspace ONE Hub Services, click the **Customization** Tab
2. Click the slider to enable the Custom (Home) tab and App Ratings.  Customize the Label/URL/Location for the Home tab.
3. Click the slider to enable People (the in-Hub directory/org chart) if desired.
4. Modify the App Catalog display by adding/removing/rearranging catalog sections.
5. Click **Save**
> NOTE: Only the Label value "Home" is localized.  If you enter any other word(s) for the label, the words will not be localized into other languages.

#### Notes about People Search ####
People functionality will not be shown in the Intelligent Hub application until Workspace ONE Access integration is configured appropriately.  People leverages the `manager` attribute to display org heirarchy (be sure to map this to `managerDN`), and the thumbnailPhoto attribute to display employee photos.  

For the purposes of a demo, the following script can be useful for populating photos into the thumbnailPhoto attribute:
```powershell
# credit to http://woshub.com/how-to-import-user-photo-to-active-directory-using-powershell/
Import-Module ActiveDirectory
Import-Csv C:\PS\import.csv | %{Set-ADUser -Identity $_.AD_username -Replace @{thumbnailPhoto=([byte[]](Get-Content $_.Photo -Encoding byte))}}
```
It leverages a CSV formatted as follows:
```
AD_username,Photo
asmith,C:\PS\asmith.jpg
klinton@adatum.com,C:\PS\klinton.jpg
jkuznetsov,C:\PS\jkuznetso.png
```

#### Enable the Hub Catalog ####
For legacy compatibility, Workspace ONE UEM does not automatically enable the in-app catalog.   Admins must enable this functionality when they are ready to begin using it.  

> In cases where you're already using Intelligent Hub for the app catalog on iOS, you may still need to validate the Hub catalog is enabled for macOS.

1. In Workspace ONE UEM, navigate to *Groups & Settings > Configurations > Intelligent Hub* 
2. Click **Configure* in the *Catalog Settings* box.
3. With the *Publishing* tab selected, enable *Intelligent Hub Catalog (macOS)* and disable *Legacy Catalog (macOS)*.
4. Click **Save**

#### Relevant Documentation: ####
* [Administering Hub Services with Workspace ONE UEM and Workspace ONE Access](https://docs.vmware.com/en/VMware-Workspace-ONE/services/intelligent-hub_IDM/GUID-7ADD4A02-DE07-4BBA-841B-40AFFDD19863.html)
* [How to Activate Hub Services](https://docs.vmware.com/en/VMware-Workspace-ONE/services/intelligent-hub_IDM/GUID-19581E5A-BC8A-465F-ABFF-C243D69393CB.html)
* [Using Hub Services without Enabling Workspace ONE Access (VMware Identity Manager)](https://docs.vmware.com/en/VMware-Workspace-ONE/services/intelligent-hub_IDM/GUID-BEFA3A94-357A-4B9C-AEC6-5B62D2BF3AEE.html)
* [Hub Services when Workspace ONE Access is Integrated](https://docs.vmware.com/en/VMware-Workspace-ONE/services/intelligent-hub_IDM/GUID-826D5409-98C6-4A37-B4A9-B3DFD244AAE8.html)


**************************************************************************************************

### 5. (Optional) Workspace ONE Access ###
Workspace ONE Access enables SSO and Conditional Access for devices enrolled in Workspace ONE UEM.  Since the breadth and depth of a Workspace ONE Acceess integration varies quite a bit, you'll most likely get the most value by reading the documents available for common scenarios.  Be sure to check out the Activity Path on TechZone as it contains hands-on labs where you can safely walk through some of these configuration scenarios before you attempt them in your own testing environment.

From the perspective of a POC or lightweight demo, you can possibly attempt this with a small instance of Office365.  Some guidance as to a typical demo setup:

1. Set up two Domain Controllers (prefer Windows Server 2016/2019) with a single domain/forest (you can use one to host the ACC and one to host the IDM Connector)
2. In the Workspace ONE Access console, set up User Attributes by navigating to *Identity & Access Management > Setup > User Attributes*.  Be sure to mark UserPrincipalName as required.  Add `objectGUID` and `mS-DS-ConsistencyGuid` as additional attributes.  Add any additional attributes you'd like exposed by "People" functionality (such as managerDN and thumbnailPhoto).
3. Set up the Identity Manager Connector by navigating to *Identity & Access Management > Setup > Connectors*.  Click **Add Connector**.
4. Set up the Directory by navigating to *Identity & Access Management > Directories*.  Click **Add Directory**.
5. Set up People Search by navigating to *Catalog (pull down) > Settings > People Search*.  Enable People Search and map attributes as appropriate.
6. Add the connector to the Built-In Identity Provider by navigating to *Identity & Access Management > Identity Providers*.  Click the **Built-In** provider and add the AD directory and connector.  Be sure to also select a connector to use and enable *Password (Cloud Deployment)* as a Connector Authentication Method.
7. Configure the Default Policy Set by navigating to *Identity & Access Management > Policies*.  Add the *Password (Cloud Deployment)* authentication option to enable login using credentials pulled from the Connector.

#### Notes Regarding Office365 Demo Setups ####
Just a few notes to help you find your way around the Office365 Integration if you're not overly familiar with Identity/Federation and the Microsoft tools:
1. Install the [AzureADPreview Powershell Cmdlets](https://social.technet.microsoft.com/wiki/contents/articles/28552.microsoft-azure-active-directory-powershell-module-version-release-history.aspx#A) -- `PS>   Install-Module -Name MSOnline`
2. Download & Install the [MS Online Services Sign-In Assistant](https://www.microsoft.com/en-us/download/details.aspx?id=41950)
3. Download & Install [Azure AD Connect](https://docs.microsoft.com/en-us/azure/active-directory/hybrid/reference-connect-version-history)
4. Configure Azure AD Connect --> select either Password Hash Synchronization or Do Not Configure.
5. When sync completes, log into the O365 Admin portal and ensure your demo "users" are licensed for Office E1 or E3.  (E3 allows you to explore graph API integration for iOS MAM controls)
6. Use Powershell to Update the domain from Managed to Federated:
```Powershell
## Set the Domain to Federated
Set-MSolDomainAuthentication -DomainName <Domain Name To Be Federated> -Authentication Federated -IssuerURI "<tenant IDM Url - e.g. yourtenant.workspaceoneair.com>" -FederationBrandName "<Domain Name to be Federated>" -PassiveLogOnURI "https://<Tenant IDM URL>/SAAS/API/1.0/POST/sso" -ActiveLogOnURI "https://<Tenant IDM URL>/SAAS/auth/wsfed/active/logon" -LogOffURI "https://login.microsoftonline.com/logout.srf" -MetadataExchangeURI "https://<Tenant IDM URL>/SAAS/auth/wsfed/services/mex" -SigningCertificate <Signing Cert downloaded from Catalog > Settings > SAML MetaData>
```

> Note - The above powershell uses the older v1 Azure AD cmdlets.   If you happen to know how to do this with the V2 preview cmdlets, please send us a pull request with an update!

#### Notes Regarding SSO via Workspace ONE Access ####
Workspace ONE Access can significally reduce the amount of username/password prompts your users endure by leveraging Certificate Authentication.   Workspace ONE UEM includes built-in CA functionality that Workspace ONE Access can leverage to generate and validate user-based certificates on the fly. To enable this functionality, you'll need to do the following:

1. In the UEM Console, navigate to *Groups & Settings > All Settings > System > Enterprise Integration > VMware Identity Manager > Configuration
2. Enable certificate provisioning and export the issuer certificate.
3. In the Workspace ONE Access console, navigate to *Identity & Access Managememnt > Authentication Methods* and edit the *Certificate (Cloud Deployment)* option.
4. **Enable** the certificate adapter.  For *Root and Intermediat CA certificates*, click **Select File** and upload the Issuer Certificate you downloaded from the UEM console.   Change the User Identifier Search Order to **upn | email | subject** and click **Save**.
5. Navigate to *Identity & Access Management > Identity Providers > Built-In*.   Associate the **Certificate (Cloud Deployment)** authentication method and click **Save**.
6. Navigate to *Identity & Access Management > Policies* and click **Edit Default Policy**.  
7. Click **Next** and then modify both rules (Web Browser and Workspace ONE App) to say the following (remember, these are rules for a small scale POC):
```
Authenticate Using...
Certifcate (Cloud Deployment)
If preceding method fails:   Password (Cloud Deployment)
If preceding method fails:   Password
If preceding method fails:   Password (Local Directory)
```
8. Click **Save** when completed.
9. In the UEM Console, click *Add > Profile > macOS > User.   Configure the General payload settings.

> For help setting up SSO profiles, refer to the [TechZone Article about Identity Preferences](https://techzone.vmware.com/blog/managing-identity-preferences-streamline-single-sign-macos).  YOu basically need to create a profile with 2 parts:  the SCEP profile pointing to the UEM-Access CA integration (for the user's identity cert), and a Custom Settings payload that sets the identity preference (e.g. ties the SCEP credential payload to the Workspace ONE Access Cert-Auth URL).

10. Click the *SCEP* payload and click **Configure**.   Choose *AirWatch Certificate Authority* for the *Source* and *Authority* fields. Choose *Certificae Authority* and ensure "allow access" is checked.   
11. Click the *Custom Settings* payload.  Paste in the following Profile (be sure to edit the Certificate payload UUID per the TechZone article).

Safari Integration:
```xml
<dict>
    <key>Name</key>
    <string>https://cas.vidmpreview.com/</string>
    <key>PayloadCertificateUUID</key>
    <string>33f1db5b-889a-4294-b3c5-c1fa9c410407</string>
    <key>PayloadUUID</key>
    <string>96635DA9-EAE8-450F-8B1D-B9EEE82E4448</string>
    <key>PayloadType</key>
    <string>com.apple.security.identitypreference</string>
    <key>PayloadDisplayName</key>
    <string>Identity Pref</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>PayloadIdentifier</key>
    <string>com.apple.security.identitypreference</string>
</dict>
```
Chrome Integration:
```xml
<dict>
<key>AutoSelectCertificateForUrls</key>
<array>
 <string>{"pattern":"https://cas.vidmpreview.com/","filter":{"ISSUER":{"CN":”TMApple"}}}</string>
</array>
<key>PayloadEnabled</key>
<true/>
            <key>PayloadDisplayName</key>
            <string>Google Chrome Settings</string>
            <key>PayloadEnabled</key>
            <true/>
            <key>PayloadIdentifier</key>
            <string>com.google.Chrome.4F720473-6832-4CE0-A895-E9C3FC6F8CBD</string>
            <key>PayloadType</key>
            <string>com.google.Chrome</string>
            <key>PayloadUUID</key>
            <string>4F720473-6832-4CE0-A895-E9C3FC6F8CBD</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
</dict>
```


#### Relevant Documentation: ####
* [Attributes that can be Enabled for People Search](https://docs.vmware.com/en/VMware-Identity-Manager/3.3/idm-administrator/GUID-F965647F-92BC-4317-92F6-D31D086EB679.html?hWord=N4IghgNiBcIC4AsCuBbARgOzASwgBwQHs5CQBfIA)
* [Workspace ONE Access (previously Identity Manager) Activity Path](https://techzone.vmware.com/becoming-identity-manager-hero)
* [VMware Identity Manager Integration with Office 365](https://www.vmware.com/pdf/vidm-office365-saml.pdf)
* [VMware Identity Manager 19.03: Configuring Certificate Authentication](https://www.youtube.com/watch?v=s4EILnnP98I)
* [Managing Identity Preferences to Streamline Single Sign-On for macOS](https://techzone.vmware.com/blog/managing-identity-preferences-streamline-single-sign-macos)

**************************************************************************************************

### 6. Apple Business (or School) Manager Automated Device Enrollment ###
Admins should leverage Apple Business Manager (or Apple School Manager) to enable out-of-box automated enrollment.  

1. Navigate to 

#### Relevant Documentation: ####
1. [ON-PREM:  Important Network Changes for Apple Fall Release 2019](https://techzone.vmware.com/blog/important-networking-changes-apple-fall-release)

**************************************************************************************************

### 7. Apple Business (or School) Manager Volume-Purchased Applications ###
Application delivery from the App Store (via Custom or Volume-Purchased Apps) is the "way forward" (per WWDC 2019) for app delivery on macOS.  VMware Workspace ONE UEM manages licenses and assignments through an integration with Apple Business (or School) Manager Locations.  To facilitate this integration, you must download a file from Apple Business

**************************************************************************************************
**************************************************************************************************


## Setting Up Configuration Management (Profile Payloads)


**************************************************************************************************
**************************************************************************************************


## Setting Up 3rd-Party Non-Store Applications ##
Use the following procedure to deliver Non-App Store applications to macOS.  Examples of software delivered in this method include Web Browsers (FireFox and/or Chrome), Virtual App Delivery Agents (Horizon or Citrix clients), and Tools/Utilities.

### Process the App Installer with VMware AirWatch Admin Assistant (VAAA) App ###
The [VAAA app](https://awagent.com/AdminAssistant/VMwareAirWatchAdminAssistant.dmg) is basically a GUI wrapper for a tool that generates a metadata file used by the Workspace ONE Intelligent Hub to deploy non-store apps.

1. Open the VAAA app and either browse for a DMG/PKG/MPKG file or drag-n-drop it on the UI.
2. VAAA processes the file and outputs it to a folder in your `~\Documents` folder.
3. Click the magnifying glass to open to the location in Finder.

### Add the App to Workspace ONE UEM ###

1. In Workspace ONE UEM, Navigate to *Apps & Books > List View > Internal Apps*
2. Click **Add App** 
3. Upload dmg/pkg, metadata plist, icon, and configure relevant information (including categories)
4. Add a postinstall script to leverage hubcli ("Hub Command Line Interface") to generate notifications to the user when the install completes:

```bash
/usr/local/bin/hubcli notify -t "BBEdit Installed"  -i "Workspace ONE has finished installing BBEdit" -a "Open BBEdit" -b "usr/bin/open /Applications/BBEdit.app" -c "Close"
```

> Run `/usr/local/bin/hubcli` in Terminal to view help and usage details.

5. Click **Save & Assign**
6. Choose assignment groups, Blocking Apps, and Catalog/Desired State Behavior.
7. Publish the application.


**************************************************************************************************
**************************************************************************************************

## Setting Up Initial Notification for Intelligent Hub ##
While a number of customers have taken advantage of Bootstrap functionality introduced in UEM 9.2 for "onboarding splash screens," we've started to see an uptick in customers simplifying the onboarding process.   In these slimmed-down use cases, the focus has been shifted to employee experience and self-service.   Basically, the goal is to get the user to a minimally provisioned desktop as soon as possible.   In this scenario, very few apps are auto-deployed and instead the user is notified to start the VMware Intelligent Hub to explore the available app catalog and choose the apps they want installed.

In this scenario, an admin can accomplish this in one of two ways: the Products framework, or the Internal Apps framework.  Either one works, it's more a matter of preference to the admin.   In both cases, the auto-deployed package doesn't run until the user is logged-in to macOS.

### OPTION 1:  Use the Products Framework ###

1.	Navigate to *Devices > Provisioning > Components > Files/Actions*
2.	Click *Add Files/Actions* > *macOS*
3.	Enter a Name:  macOS Onboarding Notification
4.	Click the **Manifest** tab, then click **Add Action**
  - Action to Perform:   Run
  - Command Line:  
```bash
/usr/local/bin/hubcli notify -t "Welcome To Your Mac"  -i "Open your Hub to start requesting Applications" -a "Open Intelligent Hub" -b "usr/bin/open /Applications/Workspace\ ONE\ Intelligent\ Hub.app" -c "Close"
```
5. Click **Save**, then **Save**
6. Navigate to *Devices > Provisioning > Product List View*
7. Click **Add Product** > **macOS**
8. Enter a Name:  macOS Onboarding Notification
9. Assign one or more Smart Groups (such as "All Devices" or the OG name)
10. Click on the **Manifest** tab and click **Add**
  - Actions to perform:  **Install Files/Actions**
  - Files/Actions:  **macOS Onboarding Notification**
11	Click **Save**
12.	Click **Activate** then **Activate**

### OPTION 2:  Use the Internal Apps Framework ###
In this case, an admin can create a [payload-free package](https://techzone.vmware.com/distributing-scripts-macos-vmware-workspace-one-operational-tutorial#1037001) (containing just the script) to the device.  In this scenario, you can still leverage the same command for hubcli as was used for Option 1 (Products)  


### Relevant Documentation:  ###
* [Distributing Scripts as Internal Apps for macOS](https://techzone.vmware.com/distributing-scripts-macos-vmware-workspace-one-operational-tutorial#1037001)


