# iOS 16 Shared Device Configuration command #

Paste the entire XML snippet (`<dict>...</dict>`) into the [Custom Command](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/2011/tvOS_Platform/GUID-AWT-CUST-COMMAND.html) prompt in Workspace ONE UEM.

```xml
<dict>
  <key>RequestType</key>
  <string>Settings</string>
  <key>Settings</key>
  <array>
    <dict>
      <key>Item</key>
      <string>SharedDeviceConfiguration</string>
      <key>ManagedAppleIDDefaultDomains</key>
      <array>
        <string>domain1.com</string>
        <string>domain2.com</string>
      </array>
      <key>OnlineAuthenticationGracePeriod</key>
      <integer>5</integer>
    </dict>
  </array>
</dict>
```

## Key Descriptions ##

| Key              | type      | Presence   | Description                      |
|------------------|-----------|------------|----------------------------------|
|`ManagedAppleIDDefaultDomains`   | [string]   | optional | A list of domains that the Shared iPad login screen displays. The user can pick a domain from the list to complete their Managed Apple ID. If this list contains more than 3 domains, the system picks 3 at random for display.Available in iOS 16 and later.      |
|`OnlineAuthenticationGracePeriod`   |  integer   | optional | A grace period (in days) for Shared iPad online authentication. The Shared iPad only verifies the user’s passcode locally during login for users that already exist on the device. However, the system requires an online authentication (against Apple’s identity server) after the number of days specified by this setting. Setting this value to 0 enforces online authentication every time. Available in iOS 16 and later.      |
