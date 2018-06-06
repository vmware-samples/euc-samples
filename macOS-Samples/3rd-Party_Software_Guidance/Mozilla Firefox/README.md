# Mozilla Firefox #

## Overview
- **Authors**: Robert Terakedis
- **Email**: rterakedis@vmware.com
- **Date Created**: 5/9/2018
- **Supported Platforms**: AirWatch version 9.3+
- **Tested on macOS Versions**: macOS High Sierra

## Purpose
Policies for macOS are specified in the policies.json file which is placed in the distribution directory (/Applications/Firefox.app/Content/Resources/distribution/).  Be mindful of which policies you wish to deploy, as some are only available for the Extended Support Release (ESR) version of Firefox.

> The ESR release is a SEPARATE download.  ESR functionality does not apply in the non-ESR download/installer.

To deploy with VMware Workspace ONE UEM, add FireFox as an internal application and then use the included deploypolicy.sh as a post-install script (note the replacement of XML characters per https://github.com/munki/munki/wiki/Pre-And-Postinstall-Scripts): 

The contents of the json should look similar to this (modify or remove items as needed):

```json
{
    "policies": {
        "BlockAboutAddons": true,
        "BlockAboutConfig": true,
        "BlockAboutSupport": true,
        "CreateMasterPassword": false,
        "DisableAppUpdate": true,
        "DisableBuiltinPDFViewer": true,
        "DisableDeveloperTools": true,
        "DisableFeedbackCommands": true,
        "DisableFirefoxScreenshots": true,
        "DisableFirefoxAccounts": true,
        "DisableFormHistory": true,
        "DisablePocket": true,
        "DisablePrivateBrowsing": true,
        "DisableSecurityBypass": {
            "InvalidCertificate": true, 
            "SafeBrowsing": true        
            },
        "DisableSysAddonUpdate": true,
        "DisplayBookmarksToolbar": true,
        "DisplayMenuBar": true,
        "DontCheckDefaultBrowser": true,
        "RememberPasswords": false,
        "NoDefaultBookmarks": true,
        "OfferToSaveLogins": false,
        "Homepage": {
            "URL": "http://www.vmware.com/",
            "Locked": true,
            "Additional": ["http://www.air-watch.com/",
                           "http://techzone.vmware.com/"]
            },
        "Popups": {
            "Allow": ["http://vmware.com/",
                      "http://air-watch.com/"]
            },
        "Cookies": {
            "Allow": ["http://vmware.com/",
                      "http://air-watch.com/"],
            "Block": ["http://example.edu/"]
            },
        "Bookmarks": [
            {"Title": "VMware TechZone",
             "URL": "https://techzone.vmware.com",
             "Favicon": "https://techzone.vmware.com/favicon.ico",
             "Placement": "toolbar",
             "Folder": "Bookmarks"
            }
            ],
        "WebsiteFilter": {
            "Block": ["<all_urls>"],
            "Exceptions": ["*://*.vmware.com/*",
                           "*://*.dell.com/*",
                           "*://*.apple.com/*"]
            }
        
    }
}
```

There's more than the example policies shown above at the Github link listed below in "Additional Resources".   Use the Github Readme for reference to build the policies.json file appropriate for your environment/needs/requirements.


## Required Changes/Updates
None

## Change Log
- 5/9/2018: Created Initial File


## Additional Resources
- [Deploying Firefox in an Enterprise Environment -- Mozilla](https://developer.mozilla.org/en-US/Firefox/Enterprise_deployment)
- [Customizing Firefox using policies.json -- Mozilla](https://support.mozilla.org/en-US/kb/customizing-firefox-using-policiesjson)
- [FireFox ESR Downloads -- Mozilla](https://www.mozilla.org/en-US/firefox/organizations/all/)
- [Policy Templates (Github Repo) -- Mozilla](https://github.com/mozilla/policy-templates/blob/master/README.md)


