# Carbon Black Defense

## Overview

- **Authors**: John Richards, Robert Terakedis
- **Email**: jrichards@vmware.com, rterakedis@vmware.com
- **Date Created**: 2020-04-24
- **Supported Platforms**: Workspace ONE UEM 2003
- **Tested on macOS Versions**: macOS Catalina

## Purpose

Install the Carbon Black Defense agent via unattended installation using Workspace ONE UEM.

1) Download the Carbon Black Defense installer package for macOS (generally *confer_installer_mac-<version>.dmg*)
2) Parse the installer with the [Workspace ONE Admin Assistant](https://awagent.com/AdminAssistant/VMwareAirWatchAdminAssistant.dmg)
3) Modify the generated plist file as instructed in [Modify PkgInfo Plist File](#modify-pkginfo-plist-file)
4) Upload the dmg, plist, and icon to Workspace ONE UEM as an Internal App (Apps & Books > Native > Internal)
5) In the __Scripts__ tab, add the script described in [Modify Scripts for Internal App](#modify-scripts-for-internal-app)
6) Configure any remaining deployment settings and Assign the app as appropriate

## Modify PkgInfo Plist File

Current versions of the installer package for Carbon Black Defense require running an install script from the same location as the installer package. To meet this requirement, you must add a new array into the plist file which forces the Workspace ONE Intelligent Hub to unpack the DMG to a known temporary location so you can execute the install script with the required parameters.

```XML
<key>items_to_copy</key>
<array>
    <dict>
        <key>destination_path</key>
        <string>/tmp/</string>
        <key>mode</key>
        <string>644</string>
        <key>source_item</key>
        <string>CbDefense Install.pkg</string>
    </dict>
    <dict>
        <key>destination_path</key>
        <string>/tmp/</string>
        <key>mode</key>
        <string>755</string>
        <key>source_item</key>
        <string>docs/cbdefense_install_unattended.sh</string>
    </dict>
</array>
```

## Modify Scripts for Internal App

In order to run the installer which you've unpacked to a temporary location, you must add a Postinstall script to the deployment.   Under the __Scripts__ tab when configuring the application deployment, you must paste something similar to the following in the Postinstall Script textbox.  Be sure to replace the *COMPANY_CODE* and *group_name* with details relevant to your own company's installer.   You should be able to find these values in the Carbon Black console.

```BASH
#!/bin/sh
./tmp/cbdefense_install_unattended.sh -i '/tmp/CbDefense Install.pkg' -c 'COMPANY_CODE' -g group_name
```

## Required Changes/Updates

None

## Change Log

- 2020-04-24: Created Initial File
- 2020-06-16: Fixed copy/paste error

## Additional Resources

- [CB Defense: How to perform an unattended installation of the Mac Sensor](https://community.carbonblack.com/t5/Knowledge-Base/CB-Defense-How-to-Perform-an-Unattended-Installation-of-the-Mac/ta-p/66584)
