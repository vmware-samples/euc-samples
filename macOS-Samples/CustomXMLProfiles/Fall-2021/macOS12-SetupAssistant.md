## macOS 12 Setup Assistant ##

This is a net new payload for skipping Setup Assistant screens.

This payload includes:
* Skip Apple Watch unlock screen

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
    <key>SkipUnlockWithWatch</key>
    <true />
    <key>PayloadDisplayName</key>
    <string>SetupAssistant</string>
    <key>PayloadDescription</key>
    <string>SetupAssistant</string>
    <key>PayloadIdentifier</key>
    <string>195c2047-813f-423e-b8c6-56a47a721b6e.SetupAssistant</string>
    <key>PayloadOrganization</key>
    <string></string>
    <key>PayloadType</key>
    <string>com.apple.SetupAssistant.managed</string>
    <key>PayloadUUID</key>
    <string>56238411-4d7b-45c5-a876-4d3geae7XXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
    <key>PayloadVersion</key>
    <integer>1</integer>
</dict>
```
