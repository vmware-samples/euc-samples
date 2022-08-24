# iOS 16 DNS Proxy profile #

Paste the entire XML snippet (`<dict>...</dict>`) into the [Custom Settings payload](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/2011/iOS_Platform/GUID-AWT-PROFILECUSTOMSETTS.html) in Workspace ONE UEM.

```xml
<dict>
    <key>PayloadDescription</key>
    <string>Configures a DNS Proxy</string>
    <key>PayloadDisplayName</key>
    <string>DNS Proxy</string>
    <key>PayloadIdentifier</key>
    <string>0558C5B9-CD9F-4845-82F9-7C51AEEEF967</string>
    <key>PayloadOrganization</key>
    <string></string>
    <key>PayloadType</key>
    <string>com.apple.dnsProxy.managed</string>
    <key>PayloadUUID</key>
    <string>5855b9b4-d7ae-41f6-9581-0b748e96cb98</string>
    <key>PayloadVersion</key>
    <integer>1</integer>

    <key>AppBundleIdentifier</key>
    <string>com.app.sample</string>

    <key>ProviderBundleIdentifier</key>
    <string></string>
    
    <key>ProviderConfiguration</key>
    <dict>
    </dict>

    <key>DNSProxyUUID</key>
    <string>BC894D14-2FD0-49E7-8B64-A9AC11320BEB</string> 

</dict>
```

## Key Descriptions ##

| Key           | Type          | Presence | Description   |
|---------------|---------------|----------|---------------|
|`AppBundleIdentifier`|string     | required |The bundle identifier of the app containing the DNS proxy network extension.     |
|`ProviderBundleIdentifier`|string|option    |The bundle identifier of the DNS proxy network extension to use. Declaring the bundle identifier is useful for apps that contain more than one DNS proxy extension.                                                 |
|`ProviderConfiguration`|dictionary|optional |The dictionary of vendor-specific configuration items.                       |
|`DNSProxyUUID`  | string         |optional  |A globally-unique identifier for this DNS proxy configuration. Managed apps with the same 'DNSProxyUUID' in their app attributes have their DNS lookups traffic processed by the proxy.                            |
