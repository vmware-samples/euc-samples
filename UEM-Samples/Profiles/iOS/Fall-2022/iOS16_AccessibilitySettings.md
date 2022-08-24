# iOS 16 Set Accessibility Settings command #

Paste the entire XML snippet (`<dict>...</dict>`) into the [Custom Command](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/2011/tvOS_Platform/GUID-AWT-CUST-COMMAND.html) prompt in Workspace ONE UEM.

```xml
<dict>
  <key>RequestType</key>
  <string>Settings</string>
  <key>Settings</key>
  <array>
    <dict>
      <key>Item</key>
      <string>AccessibilitySettings</string>
      <key>BoldTextEnabled</key>
      <true/>
      <key>IncreaseContrastEnabled</key>
      <true/>
      <key>ReduceMotionEnabled</key>
      <true/>
      <key>ReduceTransparencyEnabled</key>
      <true/>
      <key>TextSize</key>
      <integer>6</integer>
      <key>TouchAccommodationsEnabled</key>
      <true/>
      <key>VoiceOverEnabled</key>
      <true/>
      <key>ZoomEnabled</key>
      <true/>   
    </dict>
  </array>
</dict>
```

## Key Descriptions ##

| Key              | type      | Presence   | Description                      |
|------------------|-----------|------------|----------------------------------|
|`BoldTextEnabled`   | boolean   | optional | If true, enables bold text.      |
|`IncreaseContrastEnabled`| boolean|optional|If true, enables increase contrast.|
|`ReduceMotionEnabled`| boolean| optional   | If true, enables reduced motion. |
|`ReduceTransparencyEnabled`|boolean|optional|If true, enables reduced transparency.|
|`TextSize`         | integer  | optional   | The accessibility text size apps that support dynamic text use. 0 is the smallest value, and 11 is the largest available.               |
|`TouchAccommodationsEnabled`| boolean | optional | If true, enables touch accommodations. |
|`VoiceOverEnabled` | boolean    | optional   | If true, enables voiceover. |
| `ZoomEnabled`     | boolean    | optional   | If true, enables zoom.            |
