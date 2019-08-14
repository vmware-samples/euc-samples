# macOS Proof-of-Concept Guide #
As organizations are embracing employee choice or embarking on their own [“Digital Transformation,”](https://techzone.vmware.com/blog/i-talked-160-customers-past-year-about-their-euc-plans-heres-what-i-learned) one thing became clear:  there’s a number of “accidental macOS admins.”  This guide aims to help anyone new to the macOS Platform (coming from iOS/Android, coming from traditional Windows management, or just starting out). 

As always, contributions from the community are welcome, so if you find something missed (or have something to share) as you go through this guide, send us a pull request!

## Pre-Requisites to macOS Management ##

### Apple Push Notification Service (APNS) ###
APNS provides notifications to the macOS mdmclient (user and device) instructing it to check-in for commands. If you’re already managing iOS devices, this may already be completed.

* Navigate to *Devices > Devices Settings > Apple > APNs for MDM*
* Select *Override > Generate New Certificate*
* Download `MDM_APNsRequest.plist`
* Go to Apple’s Website linked in the UEM Console & Authenticate
* Click *Create a Certificate* and  Accept TOU
* Upload the MDM plist and download the PEM
* Upload PEM in Workspace ONE & Save

> [APNS (Apple Push Notification Service) Documentation (VMware)](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/9.6/vmware-airwatch-guides-96/GUID-AW96-DevicesUsers_Apple_APN.html)
> [Generating & Renewing APNS certificates (VMware)](https://support.air-watch.com/articles/115001662728)

> APNS required for macOS MDM Manageability


### AirWatch Cloud Messaging (AWCM) ###
AWCM provides notifications to the VMware Intelligent Hub for macOS, allowing value-add functionality in the Hub to occur in real-time.  

> NOTE:  This setup is already done if SaaS-hosted!  

* Ensure you installed AWCM from the downloaded Workspace ONE UEM installer.
* Navigate to *Settings > System > Advanced > Secure Channel Certificate*
* Download and Install **AWCM Secure Channel Certificate Installer** on AWCM Servers

### Hub Services ###
Hub Services is a cloud-hosted component that drives the Hub-based App catalog.  When combined with Workspace ONE Access integration, Hub Services enable the full digital experience (Unified Catalog, People, Notifications, etc) in the Intelligent Hub app.

### (Optional) Workspace ONE Access ###
Workspace ONE Access enables SSO and Conditional Access for devices enrolled in Workspace ONE UEM.


### Apple Business (or School) Manager Automated Device Enrollment ###
Admins should leverage Apple Business Manager (or Apple School Manager) to enable out-of-box automated enrollment.  


### Apple Business (or School) Manager Volume-Purchased Applications ###


