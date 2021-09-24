## Recommendation cadence for software updates. ##

This payload includes:
* Recommendation cadence


Paste the entire XML snippet (`<dict>...</dict>`) into the Custom Command modal of a device in Workspace ONE UEM.

```xml
<dict>
  <key>RequestType</key>
  <string>Settings</string>
  <key>Settings</key>
  <array>
    <dict>
      <key>Item</key>
      <string>SoftwareUpdateSettings</string>
      <key>RecommendationCadence</key>
      <integer>1</integer> <!--The possible values are 0 (default), 1, and 2.-->
    </dict>
  </array>
</dict>
```
