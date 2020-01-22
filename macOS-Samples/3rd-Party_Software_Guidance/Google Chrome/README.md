# Google Chrome #

## Overview
- **Authors**: Robert Terakedis, John Richards, Adam Matthews
- **Email**: rterakedis@vmware.com, jrichards@vmware.com
- **Date Created**: 4/17/2018
- **Supported Platforms**: AirWatch version 9.3
- **Tested on macOS Versions**: macOS High Sierra

## Purpose
Manage Google Chrome Settings as Supported by Google via Workspace ONE:

1) Download the 64-bit Enterprise Bundle from Google (link below in [Resources](#Additional-Resources))
2) Review the [Chrome Policy List online](https://cloud.google.com/docs/chrome-enterprise/policies/) or using chrome_policy_list.html found in GoogleChromeEnterpriseBundle64/Documentation/Chrome\ Policies/{language}/
3) The Custom XML file in this folder is derived from the *com.google.Chrome.plist* file in the Enterprise Bundle (GoogleChromeEnterpriseBundle64/Configuration/com.google.Chrome.plist).  Review and modify as needed for your organization as based on the Chrome Policy List
4) Deploy the Chrome Browser for Enterprise app in order to leverage the policies configured in the preferences (via Custom XML)

## Notes Regarding VMware Identity Manager Cert-based Authentication
To manage the Certicficate Picker, use the **AutoSelectCertificateForUrls** key and set the Pattern URL to the CAS URL of your Identity Manager Instance:

* *.vmwareidentity.com = https://cas-aws.vmwareidentity.com/
* *.vmwareidentity.eu = https://cas-aws.vmwareidentity.eu/
* *.vidmpreview.com = https://cas.vidmpreview.com/

The Issuer needs to be the Issuer of your CA. So if your Issuer is CA is **CN=lab-ad01-CA** use **lab-ad01-CA**. 



## Required Changes/Updates
None

## Change Log
- 1/22/2020: Updated Google Chrome Policies Location
- 3/22/2018: Created Initial File
- 4/27/2018: Added postinstall script to suppress some first run prompts
- 11/28/2018:  Added AutoSelectCertificateForUrls key for Identity manager Integration (Thanks @adammatthews!)


## Additional Resources
- [List of Policy Keys for Chrome](https://www.chromium.org/administrators/policy-list-3)
- [Chrome Browser for Enterprise -- Google](https://enterprise.google.com/chrome/chrome-browser)
