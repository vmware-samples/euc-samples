# Google Chrome

## Overview

- **Authors**: Robert Terakedis, John Richards, Adam Matthews
- **Email**: rterakedis@vmware.com, jrichards@vmware.com
- **Date Created**: 4/17/2018
- **Supported Platforms**: AirWatch version 9.3
- **Tested on macOS Versions**: macOS High Sierra

## Purpose

Manage Google Chrome Settings as Supported by Google via Workspace ONE:

1) Download the 64-bit Enterprise Bundle from Google (link below in [Resources](#Additional-Resources))
2) Review the [Chrome Policy List online](https://cloud.google.com/docs/chrome-enterprise/policies) or using chrome_policy_list.html found in GoogleChromeEnterpriseBundle64/Documentation/Chrome\ Policies/{language}/
3) The Custom XML file in this folder is derived from the *com.google.Chrome.plist* file in the Enterprise Bundle (GoogleChromeEnterpriseBundle64/Configuration/com.google.Chrome.plist).  Review and modify as needed for your organization as based on the Chrome Policy List
4) Deploy the Chrome Browser for Enterprise app in order to leverage the policies configured in the preferences (via Custom XML)

## Notes Regarding VMware Identity Manager Cert-based Authentication

To manage the Certicficate Picker, use the **AutoSelectCertificateForUrls** key and set the Pattern URL to the CAS URL of your Identity Manager Instance:

- *.vmwareidentity.com = https://cas-aws.vmwareidentity.com/
- *.vmwareidentity.eu = https://cas-aws.vmwareidentity.eu/
- *.vidmpreview.com = https://cas.vidmpreview.com/

The Issuer needs to be the Issuer of your CA. So if your Issuer is CA is **CN=lab-ad01-CA** use **lab-ad01-CA**. 

## Notes Regarding Kerberos Authentication

To enable Kerberos Authentication, you'll need to explore the use of two policies:  AuthServerWhitelist and AuthNegotiateDelegateWhitelist.  More information about these two policies can be found in the [List of Policy Keys for Chrome](https://cloud.google.com/docs/chrome-enterprise/policies).

## Notes Regarding Chrome Browser Cloud Management

There have been some great significant advancements in the Google Admin console to centrally manage and easily quickly see the status of Chrome Browser across your business desktop endpoints.  With Chrome Browser Cloud Management, you can quickly see reports on deployed versions, device information, apps, and extensions installed, or management policies applied. From the Google Admin console, you can also take quick action on devices, such as blocking or force-installing a specific extension.  Users need not sign in to Google to enable Cloud Management. Instead, Workspace ONE administrators manage the devices with “enrollment tokens” that are Globally Unique Identifiers (GUID) randomly generated in the Google Admin console. These tokens can be used for many devices or just one One or more devices may use a token. 
 
For reference, there is a workflow of the enrollment process in the [Chrome Browser Cloud Management whitepaper](http://bit.ly/managebrowsers).

To enable Chrome Browser Cloud Management for macOS, add the following two lines inside the [Example Custom Settings XML](#Example-Custom-Settings-XML) displayed below:

```XML
    <key>CloudManagementEnrollmentToken</key>
    <string>XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX</string>
    <key>CloudManagementEnrollmentMandatory</key>
    <true/>
```

## Example Custom Settings XML

```XML
<dict>
    <key>AutoSelectCertificateForUrls</key>
    <array>
    <string>{"pattern":"https://cas.vidmpreview.com","filter":{"ISSUER":{"CN":”TMApple"}}}</string>
    </array>
     <key>BuiltInDnsClientEnabled</key>
    <false />
    <key>AuthServerWhitelist</key>
    <string>*.domain.com</string>
    <key>AuthNegotiateDelegateWhitelist</key>
    <string>*.domain.com</string>
    <key>PayloadEnabled</key>
    <true/>
    <key>PayloadDisplayName</key>
    <string>Google Chrome Settings</string>
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

## Required Changes/Updates

None

## Change Log

- 2020-02-27: Added Notes Regarding Chrome Browser Cloud Management
- 2020-01-21: Updated Google Chrome Policies Location
- 2018-11-28:  Added AutoSelectCertificateForUrls key for Identity manager Integration (Thanks @adammatthews!)
- 2018-04-27: Added postinstall script to suppress some first run prompts
- 2018-03-22: Created Initial File

## Additional Resources

- [List of Policy Keys for Chrome](https://cloud.google.com/docs/chrome-enterprise/policies)
- [Chrome Browser for Enterprise -- Google](https://enterprise.google.com/chrome/chrome-browser)
