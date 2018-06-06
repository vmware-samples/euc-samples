#!/bin/bash
/bin/mkdir -p /Applications/Firefox.app/Contents/Resources/distribution
/usr/bin/touch /Applications/Firefox.app/Contents/Resources/distribution/policies.json

cat << EOF > /Applications/Firefox.app/Contents/Resources/distribution/policies.json
{
    "policies": {
        "BlockAboutAddons": true,
        "BlockAboutConfig": true,
        "BlockAboutSupport": true,
        "CreateMasterPassword": false,
        "DisableAppUpdate": false,
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
        "OverrideFirstRunPage": "https://www.vmware.com",
        "OverridePostUpdatePage": "https://www.vmware.com",
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
EOF