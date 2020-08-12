## iOS 14 WiFi ##

This payload includes:
* Disable MAC address randomization

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>PayloadDescription</key>
  <string>Configures wireless connectivity settings.</string>
  <key>PayloadDisplayName</key>
  <string>WiFi (Example Wi-Fi)</string>
  <key>PayloadIdentifier</key>
  <string>195c2047-813f-423e-b8c6-56a47a721b6e.Wi-Fi</string>
  <key>PayloadOrganization</key>
  <string></string>
  <key>PayloadType</key>
  <string>com.apple.wifi.managed</string>
  <key>PayloadUUID</key>
  <string>36297c23-1c2f-43e9-8863-bea2c33ca318</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
  <key>ProxyType</key>
  <string>None</string>
  <key>SSID_STR</key>
  <string>Example Wi-Fi</string>
  <key>DisableAssociationMACRandomization</key>
  <true/>
</dict>
```
