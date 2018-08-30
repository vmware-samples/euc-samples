# Adobe Creative Cloud Suite #

## Overview
- **Authors**: Robert Terakedis, Daniel Machin
- **Email**: rterakedis@vmware.com, [@drmachin](https://twitter.com/drmachin)
- **Date Created**: 8/29/2018
- **Supported Platforms**: AirWatch version 9.6
- **Tested on macOS Versions**: macOS High Sierra (10.13.6)

## Purpose
When deploying Adobe Creative Cloud (CC) products with Workspace ONE UEM, admins should strongly consider using the integrated munki functionality built into "Internal Apps."   By using Internal Apps, admins gain the benefit of code which already understands the unique nature of the Creative Cloud app packages and handles them appropriately.  That said, as a macOS administrator, there is still some manual work which must be done to deliver these Adobe CC packages successfully.

*__NOTE:   Adobe recommends using Creative Cloud Packager to package a single application at a time.   In other words, you should have a "Photoshop" package, an "InDesign" package, a "Lightroom" package, etc.   Do not attempt to package the entire creative cloud suite into a single installer package.__*

## High Level Overview ##
The following describes the basic process for deploying an Adobe Creative Cloud app using the Creative Cloud Packager app for a serialized install.  This process may differ slightly if you use named-user licensing (feel free to update and send us a pull request! )

1. Use the Adobe Creative Cloud Packager to create a single app installer (e.g. Photoshop)
2. From within the "Build" folder of the CCP output, take the installer PKG file and parse it with the VMware AirWatch Admin Assistant app.
3. Modify the metadata plist file as follows:
   1. Set "Uninstallable" to `<true/>`
    ```xml
        <key>uninstallable</key>
        <true/>
    ```

   2. Modify the "installs" array with information pertinent to the actual application which is installed.  By default, the installs key points to a pimx file, but *should* instead contain information about the paths to the installed apps.  As an example:
    ```xml
        <key>installs</key>
        <array>
            <dict>
                <key>CFBundleIdentifier</key>
                <string>com.adobe.Photoshop</string>
                <key>CFBundleName</key>
                <string>Photoshop CC</string>
                <key>CFBundleShortVersionString</key>
                <string>19.1.6</string>
                <key>CFBundleVersion</key>
                <string>19.1.6.784</string>
                <key>minosversion</key>
                <string>10.11.0</string>
                <key>path</key>
                <string>/Applications/Adobe Photoshop CC 2018/Adobe Photoshop CC 2018.app</string>
                <key>type</key>
                <string>application</string>
                <key>version_comparison_key</key>
                <string>CFBundleShortVersionString</string>
            </dict>
        </array>
    ```

4.  When you upload the application to Workspace ONE UEM, set the *Uninstall Method* to *Uninstall Script* under the **Scripts** tab.

5. Set the *Uninstall Script* to the appropriate Adobe Uninstall Command line (per the "Deploy Packages" resource below).  As an example:  
    ```bash
        /Applications/Utilities/Adobe Creative Cloud/HDCore/Setup --uninstall=1 --sapCode=PHSP --baseVersion=17.0 --platform=osx10-64 --deleteUserPreferences=true
    ```
    ![Uninstall Script](Uninstall_Script.png)

    *NOTE:   You can find the appropriate platform and sapCodes [here](https://helpx.adobe.com/enterprise/package/help/apps-deployed-without-their-base-versions.html)*


## Exceptions to the High Level Process ##
### Adobe Acrobat DC ###

*More to Come...*

## Required Changes/Updates
None

## Change Log
- 8/29/2018: Created Initial File


## Additional Resources
- [Deploy Packages for Adobe® Creative Cloud™ created using Adobe Creative Cloud Packager](https://helpx.adobe.com/enterprise/package/help/deploying-packages.html)
- [Adobe Platform IDs and SAP Codes](https://helpx.adobe.com/enterprise/package/help/apps-deployed-without-their-base-versions.html)
- [Munki and Adobe CC - Munki Wiki](https://github.com/munki/munki/wiki/Munki-And-Adobe-CC)
- [Self-Service Adobe CC in Munki](https://osxdominion.wordpress.com/2016/10/19/self-service-adobe-cc-in-munki/)
- [Getting Started with Adobe CC in Munki](https://justanothermacadmin.com/2017/06/21/getting-started-with-adobe-cc-and-munki/)