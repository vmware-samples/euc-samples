## Disable 32-bit prompting on macOS Mojave ##

Per the article [Prepare your institution for iOS 12 or macOS Mojave](https://support.apple.com/en-us/HT209028)

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
    <key>PayloadDisplayName</key>
    <string>Disable 32-bit Warnings</string>
    <key>PayloadEnabled</key>
    <true/>
    <key>PayloadIdentifier</key>
    <string>com.apple.coreservices.uiagent.C8CFE52B-9E99-469C-B55F-19BBB32CD60C</string>
    <key>PayloadType</key>
    <string>com.apple.coreservices.uiagent</string>
    <key>PayloadUUID</key>
    <string>C8CFE52B-9E99-469C-B55F-19BBB32CD60C</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>CSUIDisable32BitWarnings</key>
    <true/>
</dict>
```
