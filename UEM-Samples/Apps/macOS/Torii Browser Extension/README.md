# Torii Browser Extension

## Overview

- **Authors**: Robert Terakedis
- **Email**: rterakedis@vmware.com
- **Date Created**: 07/27/2021


## Purpose

Deploy the Torii Extension for various browsers on macOS.

## Deploy Torii Chrome Extension

1) Download the [Torii Extension Mobileconfig](https://s3-us-west-2.amazonaws.com/torii-static/extensions/chrome/jamf/torii_extension.mobileconfig)
2) Open the mobileconfig in a text editor (such as Visual Studio Code, or BBEdit).
3) Note the use of the [ExtensionInstallForcelist](https://chromeenterprise.google/policies/#ExtensionInstallForcelist) key from the [Chrome Policy List online](https://cloud.google.com/docs/chrome-enterprise/policies).
4) Determine the best method to deploy in your environment:  New Custom Settings payload, Modify Existing Custom Settings Payload, or Modify Chrome Enterprise Console Settings.

### New Custom Settings Payload

Create a new [Custom Settings](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/macOS_Platform/GUID-AWT-PROFILES-OVERVIEW.html#configure-a-custom-settings-profile-43) profile for macOS in Workspace ONE UEM:

1) Create a new macOS Device Profile and complete the *General Settings* pane
2) Select *Custom Settings* and click *Configure*
3) Paste the Payload Content from the downloaded mobileconfig.  You need the `<dict>...</dict>` in the `PayloadContent` array as follows:

```XML
<dict>
    <key>PayloadType</key>
    <string>com.apple.ManagedClient.preferences</string>
    <key>PayloadVersion</key>
    <integer>2</integer>
    <key>PayloadIdentifier</key>
    <string>org.extension.profiles.com.google.Chrome.customsettings</string>
    <key>PayloadUUID</key>
    <string>b6b2222a-4246-11e8-842f-0ed5f89f718b</string>
    <key>PayloadEnabled</key>
    <true/>
    <key>PayloadDisplayName</key>
    <string>Google Chrome Preferences</string>
    <key>PayloadContent</key>
    <dict>
        <key>com.google.Chrome</key>
        <dict>
            <key>Forced</key>
            <array>
                <dict>
                    <key>mcx_preference_settings</key>
                    <dict>
                        <key>ExtensionInstallForcelist</key>
                        <array>
                            <string>khfhkedhhdbejcbapdicgagbljimakai;http://clients2.google.com/service/update2/crx</string>
                        </array>
                    </dict>
                </dict>
            </array>
        </dict>
    </dict>
</dict>
```

### Modify an existing Custom Settings Payload

If you already manage Google Chrome for macOS Settings using an existing Custom Settings payload, you'll need to modify the content of that payload to enforce the new Extension.

1) Open your existing Custom Settings profile and click *Add Version*
2) Click on the *Custom Settings* payload and examine the content of the custom settings.  Depending on how it was configured, it may look like MCX settings (similar to the settings in the downloaded mobileconfig), or it may look like [UserDefaults](https://github.com/vmware-samples/euc-samples/blob/master/macOS-Samples/3rd-Party_Software_Guidance/Google%20Chrome/com.google.Chrome.txt).
3) In either case, look for a pre-existing `ExtensionInstallForcelist` key:

* If the key exists, add the `<string>khfhkedhhdbejcbapdicgagbljimakai;http://clients2.google.com/service/update2/crx</string>` line between `<array>...</array>`
* If the key doesn't exist, add the following code block immediately preceding any other top-level "key" value:

```XML
<key>ExtensionInstallForcelist</key>
<array>
    <string>khfhkedhhdbejcbapdicgagbljimakai;http://clients2.google.com/service/update2/crx</string>
</array>
```

### Modify Chrome Enterprise Console Settings

If you've deployed a Custom Settings payload which forces Chrome management via the Chrome Enterprise Console, you'll need to enforce the new extension in the Chrome Enterprise Console.  The following process describes how to force install one extension (from [Managing Extensions in your Enterprise](https://support.google.com/chrome/a/answer/9296680?hl=en)):

* In your Admin console, go to **Devices > Chrome management > App management**.
* Select the Torii extension.
* Select a type of setting, such as User settings or Public session settings.
* Select the organization containing the users you want to allow or block the extension for.  For complete details, see [Set Chrome policies for one app](https://support.google.com/chrome/a/answer/6177447#configure).
* Under Force Installation, turn the setting on.  Initially, an organization inherits the settings of its parent. 
* If you're changing a setting for a child organization:
  * To override an inherited value, click **Override** and then change the setting.
  * To return an overridden setting to the value of its parent, click **Inherit**.
* Click **Save**.

## Deploy Torii Extension for Microsoft Edge

The process for [deploying the Torii extension for Microsoft Edge](https://help.toriihq.com/en/articles/3645503-deploy-the-edge-extension) is very similar to Chrome. You'll need to deploy or modify an existing Custom Settings payload for Microsoft Edge settings.  Our GitHub includes an [example Custom Settings payload for Microsoft Edge](https://github.com/vmware-samples/euc-samples/tree/master/macOS-Samples/3rd-Party_Software_Guidance/Microsoft%20Edge).

Similar to Chrome, Edge uses the `ExtensionInstallForcelist` key (refer to the [Browser Policy Reference](https://docs.microsoft.com/en-us/DeployEdge/microsoft-edge-policies#extensioninstallforcelist)).   As such, you'll need to either add the key and array values, or add a new string value to an existing array:

```XML
<key>ExtensionInstallForcelist</key>
<array>
  <string>gmjfpngpkkbeicflmckbhdbnanffkihi</string>
</array>
```

## Required Changes/Updates

None

## Change Log

- 2021-07-27: Created Initial File

## Additional Resources

- [Torii Help Article - Deploy the Chrome Extension on Mac](https://help.toriihq.com/en/articles/3645472-deploy-the-chrome-extension-on-mac)
- [List of Policy Keys for Chrome](https://cloud.google.com/docs/chrome-enterprise/policies)
- [Chrome Browser for Enterprise -- Google](https://enterprise.google.com/chrome/chrome-browser)
