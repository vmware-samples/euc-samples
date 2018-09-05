## Use this template as the basis for forming Custom XML to control preference domains: ##

```xml
<dict>
    <key>PayloadDisplayName</key>
    <string>ENTER YOUR DISPLAY NAME</string>
    <key>PayloadEnabled</key>
    <true/>
    <key>PayloadIdentifier</key>
    <string>com.PREFERENCE.DOMAIN.UUIDUSEDINPAYLOADUUID</string>
    <key>PayloadType</key>
    <string>com.PREFERENCE.DOMAIN</string>
    <key>PayloadUUID</key>
    <string>8-4-4-4-12-UUID-GENERATED-FROM-uuidgen</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>BOOLEAN-KEYNAME-false/-or-true/</key>
    <false/>
    <key>STRING-KEYNAME</key>
	<string>STRING</string>
	<key>INTEGER-KEYNAME</key>
	<int>INTEGER</int>
</dict>
```

In the template, you must modify:
* The `PayloadDisplayName` string value
* The `PayloadIdentifier` string value which is a combination of the Preference Domain and a UUID
* The `PayloadType` string which is the preference domain read/written by the app (such as com.google.chrome or com.apple.touchidpolicy)
* The `PayloadUUID` string value which you can generate by running `uuidgen` in terminal
* The `<key>` and value (`<string>`, boolean, `<integer>`) and arrays which comprise the preference settings.

## More Information ##
For more information on how to build custom XML, check out [VMware AirWatch 101: XML Preferences for macOS Custom Settings Profile](https://blogs.vmware.com/euc/2017/06/xml-preferences.html)