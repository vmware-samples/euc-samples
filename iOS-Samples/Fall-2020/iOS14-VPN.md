## iOS 14 VPN ##

This payload includes:
* Prevent user disabling of on-demand

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
  <string>com.apple.vpn.managed</string>
  <key>PayloadUUID</key>
  <string>a2413850-05e2-4d30-b338-cffb1437XXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
  <key>PayloadVersion</key>
  <integer>1</integer>
  <key>UserDefinedName</key>
  <string>VPN Configuration</string>
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
  <string>com.example.tunnel</string>
  <key>VPN</key>
  <dict>
    <key>AuthenticationMethod</key>
    <string>Password</string>
    <key>RemoteAddress</key>
    <string>example.com</string>
    <key>OnDemandUserOverrideDisabled</key> <!--New feature-->
    <interger>1</interger> <!-- Options are 0 to allow override and 1 to disallow override-->
  </dict>
  <key>Proxies</key>
  <dict />
</dict>
```
