## macOS 12 Restart ##

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom Command modal of a device in Workspace ONE UEM.

```xml
<dict>
  <key>RequestType</key>
  <string>Restart</string>
  <key>NotifyUser</key>
  <true />
  <key>RebuildKernelCache</key>
  <true />
</dict>
```
