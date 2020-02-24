* **Author Name:**  Robert Terakedis (rterakedis@vmware.com)
* **Date:**  2020-02-22
* **Minimal/High Level Description:**    Notes on Deploying Microsoft Office for Mac

## Determining A Deployment Method

Microsoft Office for Mac can be distributed in one of two ways:  App Store and non-Store (via Office.com downloads).  In general, VMware recommends deploying Microsoft Office from the Mac App Store (via device-based licensing through Apple Business Manager) unless any of the following apply: 

1. You are not licensing users via Office 365 (such as using Volume Licensing).   (The Mac App Store version requires Office 365 licensing.)
2. You have strict version requirements around deployed Office apps.   (The Mac App Store only delivers the latest version of Office.)
3. You are managing devices where you wish to opt the apps into the Office "Insider" program.  (The Mac App Store versions of Office apps cannot participate in the Insiders program.)

## Configuring Microsoft Office for Mac to streamline end-user experience

1. Create a Nofifications payload (via [Custom Settings XML](https://aka.ms/office-notifications-payload)) -- Pre-Authorize Office apps to generate notifications to end-users
2. Create additional Custom Settings XML as necessary:
  - [Paul Bowden's MobileConfigs](https://github.com/pbowden-msft/MobileConfigs)
  - [Microsoft Office Preferences at EUC-Samples](https://github.com/vmware-samples/euc-samples/blob/master/macOS-Samples/CustomXMLProfiles/Microsoft%20Office%202016/Microsoft-Office-2016.md)
3. Grant Terminal and Workspace ONE Hub PPPC permissions to control MS AutoUpdate. 
  - [See Code Below](#PPPC-for-AutoUpdate)

## Maintaining Office deployed from Mac App Store via Apple Business Manager

1. Select the Office App(s) from the list of Purchased apps
2. Enable AutoUpdate

> That was easy!

## Maintaining Office deployed from Office.com

You have three different options in this scenario:

### Self-Updating via Microsoft AutoUpdate

* PROS:  No required maintenance, small update sizes, user-centric experience
* CONS:  Limited control over update frequency (default 12 hours), limited ability to enforce deadlines.

To go this route, there's nothing to really configure here except to deploy the Office apps.   Since AutoUpdate is built in and automatic, you only get [minor customization](https://github.com/vmware-samples/euc-samples/blob/master/macOS-Samples/CustomXMLProfiles/Microsoft%20Office%202016/Microsoft-Office-2016.md) through a Custom Settings payload.

### Push Update Packages As Internal Apps

* PROS: Forcibly apply updates, full control over update scheduling, messaging to user to save and close work.
* CONS:  Can be disruptive to end-user's experience and requires more bandwidth than prevoius method.

In this scenario, you'll want to follow the basic high level steps: 

1. Obtain the full Office installer from Office.com (or [macadmins.software](https://macadmins.software))
2. Parse the installer with the VMware AirWatch Admin Assistant to generate metadata.plist
3. Upload both the installer and plist into Workspace ONE UEM
4. Assign the installel

### Use Workspace ONE to trigger Microsoft AutoUpdate (msupdate command line)

* PROS: Greater control over timing, leverages Microsoft AutoUpdate intelligence/logic, minimize disruption during updates, updates can be forced for users that typically decline/defer.
* CONS: Requires more up-front configuration and coding, 

In this scenario, you'll be scripting Microsoft Autoupdate (`msupdate`) to perform the update.  Microsoft has provided a [script](https://github.com/pbowden-msft/msupdatehelper/blob/master/MSUpdateTrigger.sh) (tartgeting a competitor's MDM system) that could be potentially rewritten to make this work in Workspace UEM.  In all reality, the key takeaway from the script is this:

1. You need to check if Microsoft AutoUpdate is up-to-date first.
2. All the Microsoft Apps have a special AppID/Code in Microsoft AutoUpdate:

```APPID_WORD="MSWD2019"
APPID_EXCEL="XCEL2019"
APPID_POWERPOINT="PPT32019"
APPID_OUTLOOK="OPIM2019"
APPID_ONENOTE="ONMC2019"
APPID_SKYPEBUSINESS="MSFB16"
APPID_REMOTEDESKTOP="MSRD10"
APPID_COMPANYPORTAL="IMCP01"
APPID_DEFENDER="WDAV00"
```

3. You can then provide Microsoft AutoUpdate a list of Apps you wish to check and update: `/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --install --apps $1 --wait 600`
4. If you leverage Internal Apps within Workspace ONE UEM to perform this update, you can use the **Blocking Apps** functionality to message the user that they need to close any apps they have open.

> I highly encourage you to view Paul Bowden's MAU script and leverage what you can, as he does cover a great deal of error checking prior to kicking off the update.


## PPPC for AutoUpdate

```XML
<dict>
    <key>PayloadDescription</key>
    <string>Allows Terminal and Workspace ONE Intelligent Hub to send Apple events to Microsoft AutoUpdate</string>
    <key>PayloadDisplayName</key>
    <string>Hub Controller for Microsoft AutoUpdate</string>
    <key>PayloadIdentifier</key>
    <string>com.apple.TCC.80751D34-36B8-40E1-B0E4-2A7B51195FD2</string>
    <key>PayloadOrganization</key>
    <string>com.microsoft.office</string>
    <key>PayloadType</key>
    <string>com.apple.TCC.configuration-profile-policy</string>
    <key>PayloadUUID</key>
    <string>80751D34-36B8-40E1-B0E4-2A7B51195FD2</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>Services</key>
    <dict>
        <key>AppleEvents</key>
        <array>
            <dict>
                <key>AEReceiverCodeRequirement</key>
                <string>identifier "com.microsoft.autoupdate2" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = UBF8T346G9</string>
                <key>AEReceiverIdentifier</key>
                <string>com.microsoft.autoupdate2</string>
                <key>AEReceiverIdentifierType</key>
                <string>bundleID</string>
                <key>Allowed</key>
                <true/>
                <key>CodeRequirement</key>
                <string>anchor apple generic and identifier "com.vmware.uem.hubd" and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */ or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = S2ZMFGQM93)</string>
                <key>Comment</key>
                <string></string>
                <key>Identifier</key>
                <string>/Library/Application Support/AirWatch/hubd</string>
                <key>IdentifierType</key>
                <string>path</string>
            </dict>
            <dict>
                <key>AEReceiverCodeRequirement</key>
                <string>identifier "com.microsoft.autoupdate2" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = UBF8T346G9</string>
                <key>AEReceiverIdentifier</key>
                <string>com.microsoft.autoupdate2</string>
                <key>AEReceiverIdentifierType</key>
                <string>bundleID</string>
                <key>Allowed</key>
                <true/>
                <key>CodeRequirement</key>
                <string>anchor apple generic and identifier "com.vmware.hub.mac" and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */ or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = S2ZMFGQM93)</string>
                <key>Comment</key>
                <string></string>
                <key>Identifier</key>
                <string>com.vmware.hub.mac</string>
                <key>IdentifierType</key>
                <string>bundleID</string>
            </dict>
            <dict>
                <key>AEReceiverCodeRequirement</key>
                <string>identifier "com.microsoft.autoupdate2" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = UBF8T346G9</string>
                <key>AEReceiverIdentifier</key>
                <string>com.microsoft.autoupdate2</string>
                <key>AEReceiverIdentifierType</key>
                <string>bundleID</string>
                <key>Allowed</key>
                <true/>
                <key>CodeRequirement</key>
                <string>identifier "com.apple.Terminal" and anchor apple</string>
                <key>Comment</key>
                <string></string>
                <key>Identifier</key>
                <string>com.apple.Terminal</string>
                <key>IdentifierType</key>
                <string>bundleID</string>
            </dict>
            <dict>
                <key>AEReceiverCodeRequirement</key>
                <string>identifier "com.microsoft.autoupdate2" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = UBF8T346G9</string>
                <key>AEReceiverIdentifier</key>
                <string>com.microsoft.autoupdate2</string>
                <key>AEReceiverIdentifierType</key>
                <string>bundleID</string>
                <key>Allowed</key>
                <true/>
                <key>CodeRequirement</key>
                <string>identifier "com.apple.sshd-keygen-wrapper" and anchor apple</string>
                <key>Comment</key>
                <string></string>
                <key>Identifier</key>
                <string>/usr/libexec/sshd-keygen-wrapper</string>
                <key>IdentifierType</key>
                <string>path</string>
            </dict>
        </array>
    </dict>
</dict>
```