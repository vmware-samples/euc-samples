# Carbon Black Defense

## Overview

- **Authors**: John Richards, Robert Terakedis, Paul Evans
- **Email**: jrichards@vmware.com, rterakedis@vmware.com, pevans@vmware.com
- **Date Created**: 2020-04-24
- **Supported Platforms**: Workspace ONE UEM 2004
- **Tested on macOS Versions**: macOS Catalina

## Purpose

Install the Carbon Black Defense agent via unattended installation using Workspace ONE UEM.

1) Deploy the [Kernel Extension profile for the Carbon Black Kernel Extension](#kernel-extension-profile-for-the-carbon-black-kext).
2) Download the Carbon Black Defense installer package for macOS (generally *confer_installer_mac-<version>.dmg*)
3) Parse the installer with the [Workspace ONE Admin Assistant](https://awagent.com/AdminAssistant/VMwareAirWatchAdminAssistant.dmg)

> **Note:** Carbon Black Defense supports two installation approaches through WS1.  Two options for steps 4-6 will be covered below.

4) Modify the generated plist file as instructed in Option 1 **or** Option 2.
5) Upload the dmg, plist, and icon to Workspace ONE UEM as an Internal App (Apps & Books > Native > Internal)
6) In the __Scripts__ tab, add the script described in Option 1 **or** Option 2.

7) In the __Scripts__ tab, update the Uninstall script.
8) Configure any remaining deployment settings and Assign the app as appropriate

## Kernel Extension Profile for the Carbon Black KEXT

Workspace ONE administrators should deliver a Kernel Extension Policy payload to macOS 10.13.2 and later devices in order to allow the Carbon Black kernel extensions to run.  To do this, perform the following (or optionally add the Team ID and Bundle ID to an existing profile):

1) Click **Add > Profile > macOS > Device** and complete the General information
2) Select the **Kernel Extension Policy** payload an click configure
3) Complete the profile as necessary, and include the following information in the *Allowed Kernel Extensions* list:
  * Team ID: 7AGZNQ2S2T
  * Bundle ID: com.carbonblack.defense.kext

> **NOTE:** It is recommended to deploy the KEXT policy to eligible devices *BEFORE* deploying the Carbon Black installer.

## Option 1

#### Modify PkgInfo Plist File

Option 1 will demonstrate how to install Carbon Black Defense by staging a cfg.ini file on the target macOS device, pre-loaded with the necessary configuration information, and then running the CBDefense Install.pkg referencing that information.  The first step is to add an ```installs``` key and array to the plist file so Workspace ONE will properly identify when Carbon Black Defense is installed.

```XML
<key>installs</key>
<array>
    <dict>
        <key>CFBundleIdentifier</key>
        <string>CbDefense</string>
        <key>CFBundleName</key>
        <string>CbDefense</string>
        <key>CFBundleShortVersionString</key>
        <string>3.4.2.23</string>
        <key>CFBundleVersion</key>
        <string>3.4.2.23</string>
        <key>minosversion</key>
        <string>10.6</string>
        <key>path</key>
        <string>/Applications/Confer.app</string>
        <key>type</key>
        <string>application</string>
        <key>version_comparison_key</key>
        <string>CFBundleShortVersionString</string>
    </dict>
</array>
```

> **NOTE:** You will need to replace the *CFBundleShortVersionString* and *CFBundleVersion* values in the installs array if those are different for the particular version of the Sensor you're deploying.  You can alternatively generate these values by exporting **Confer.app** from the installer package (using an app such as [Suspicious Package](https://mothersruin.com/software/SuspiciousPackage/)) and running it through the Workspace ONE Admin Assistant app.  The plist generated in that instance will contain the appropriate *installs* array information.

#### Modify Scripts for Internal App

In order to properly stage the cfg.ini file, you must add a **Preinstall** script to the deployment. Under the Scripts tab when configuring the application deployment, you must paste something similar to the following in the Preinstall Script textbox. Be sure to replace the *COMPANY_CODE* with details relevant to your own company's installer. You should be able to find this value in the Carbon Black console.

```BASH
#!/bin/sh
PATH="/tmp/cbdefense-install"
/bin/mkdir -p "$PATH"
/usr/bin/touch "$PATH/cfg.ini"
/bin/chmod 644 "$PATH/cfg.ini"
/bin/cat > "$PATH/cfg.ini" <<- EOM
[customer]
Code=COMPANY_CODE
EOM
```

If needed, you can appended to the cfg.ini file by adding to this script between the two **EOM** keys.  Here is an example of the information that could be included in the cfg.ini file:

```BASH
[customer]
Code=${COMPANY_CODE}
ProxyServer=${PROXY_SERVER}
ProxyServerCredentials=${PROXY_CREDS}
LastAttemptProxyServer=${LAST_ATTEMPT_PROXY_SERVER}
PemFile=customer.pem
AutoUpdate={true|false}
AutoUpdateJitter={true|false}
InstallBypass={true|false}
FileUploadLimit=${FILE_UPLOAD_LIMIT}
GroupName=${GROUP_NAME}
EmailAddress=${USER_NAME}
BackgroundScan={true|false}
RateLimit=${RATE_LIMIT}
ConnectionLimit=${CONNECTION_LIMIT}
QueueSize=${QUEUE_SIZE}
LearningMode=${LEARNING_MODE}
{POC=1}
CbLRKill={true|false}
HideCommandLines={true|false}
```

## Option 2

#### Modify PkgInfo Plist File

Option 2 will demonstrate how to install Carbon Black Defense by running an install script from the same location as the installer package. To meet this requirement, you must add a new array into the plist file which forces the Workspace ONE Intelligent Hub to unpack the DMG to a known temporary location so you can execute the install script with the required parameters.

```XML
<key>installer_type</key>
<string>copy_from_dmg</string>
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
<key>installs</key>
<array>
    <dict>
        <key>CFBundleIdentifier</key>
        <string>CbDefense</string>
        <key>CFBundleName</key>
        <string>CbDefense</string>
        <key>CFBundleShortVersionString</key>
        <string>3.4.2.23</string>
        <key>CFBundleVersion</key>
        <string>3.4.2.23</string>
        <key>minosversion</key>
        <string>10.6</string>
        <key>path</key>
        <string>/Applications/Confer.app</string>
        <key>type</key>
        <string>application</string>
        <key>version_comparison_key</key>
        <string>CFBundleShortVersionString</string>
    </dict>
</array>
```

> **NOTE:** You will need to replace the *CFBundleShortVersionString* and *CFBundleVersion* values in the installs array if those are different for the particular version of the Sensor you're deploying.  You can alternatively generate these values by exporting **Confer.app** from the installer package (using an app such as [Suspicious Package](https://mothersruin.com/software/SuspiciousPackage/)) and running it through the Workspace ONE Admin Assistant app.  The plist generated in that instance will contain the appropriate *installs* array information.

#### Modify Scripts for Internal App

In order to run the installer which you've unpacked to a temporary location, you must add a **Postinstall** script to the deployment.   Under the __Scripts__ tab when configuring the application deployment, you must paste something similar to the following in the Postinstall Script textbox.  Be sure to replace the *COMPANY_CODE* and *group_name* (if needed) with details relevant to your own company's installer.   You should be able to find these values in the Carbon Black console.

```BASH
#!/bin/sh
./tmp/cbdefense_install_unattended.sh -i '/tmp/CbDefense Install.pkg' -c 'COMPANY_CODE' -g group_name
```

## Uninstall Script

To simplify the uninstall process, Carbon Black Defense includes an uninstall script located within the app bundle.  In the __Scripts__ tab, change the **Uninstall Method** to **Uninstall Script**.  Be sure to replace the *UNINSTALL_CODE* with details relevant to your own company's uninstall code.  You should be able to find this value in the Carbon Black console.

```BASH
#!/bin/sh
/Applications/Confer.app/uninstall -y -c UNINSTALL_CODE
```

## Required Changes/Updates

None

## Change Log

- 2020-04-24: Created Initial File
- 2020-06-16: Added KEXT profile info
- 2020-06-19: Added second installation option and uninstall info

## Additional Resources

- [CB Defense: How to perform an unattended installation of the Mac Sensor](https://community.carbonblack.com/t5/Knowledge-Base/CB-Defense-How-to-Perform-an-Unattended-Installation-of-the-Mac/ta-p/66584)
