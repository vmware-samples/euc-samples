## iOS 14 Per-app VPN ##

This payload includes:
* Associated and excluded domains

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>PayloadDescription</key>
  <string>Configures VPN settings, including authentication.</string>
  <key>PayloadDisplayName</key>
  <string>VPN (VPN Configuration)</string>
  <key>PayloadIdentifier</key>
  <string>195c2047-813f-423e-b8c6-56a47a721b6e.VPN</string>
  <key>PayloadOrganization</key>
  <string></string>
  <key>PayloadType</key>
  <string>com.apple.vpn.managed.applayer</string>
  <key>PayloadUUID</key>
  <string>87f9cc33-0dd5-4931-b224-371263ee511f</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
  <key>UserDefinedName</key>
  <string>VPN Configuration</string>
  <key>VPNUUID</key>
  <string>dd3a392c-5db4-4bd3-b300-89ac8569f8e0</string>
  <key>AssociatedDomains</key>
  <array>
    <string>example.com</string>
  </array>
  <key>ExcludedDomains</key>
  <array>
    <string>otherexample.com</string>
  </array>
  <key>VPNType</key>
  <string>VPN</string>
  <key>IPv4</key>
  <dict>
    <key>OverridePrimary</key>
    <integer>0</integer>
  </dict>
  <key>VendorConfig</key>
  <dict />
  <key>VPNSubType</key>
  <string>com.example.vpn</string>
  <key>VPN</key>
  <dict>
    <key>AuthenticationMethod</key>
    <string>Password</string>
    <key>RemoteAddress</key>
    <string>example.com</string>
    <key>OnDemandMatchAppEnabled</key>
    <string>True</string>
    <key>ProviderType</key>
    <string>app-proxy</string>
  </dict>
  <key>Proxies</key>
  <dict />
</dict>
```
