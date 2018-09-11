# Custom XML Payloads

Custom XML payloads are the method by which MDM vendors can manage settings and preferences which are not included in the default Configuration Profile Reference.   When reading and writing preferences, developers have two main frameworks/classes they can leverage:  NSUserDefaults and CFPreferences.

## Managing NSUserDefaults preferences 
NSUserDefaults custom xml payloads tend to more closely follow the mobileconfig style and are generally relatively flat.  As you can see in the template below, the `PayloadType` specifies the targeted set of user preferences which are read/written by the application's NSUserDefaultsController.

### Use this template as the basis for forming Custom XML to control NSUserDefaults preference domains:

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


## Managing CFPreferences preferences 
CFPreferences custom xml payloads tend to seem slightly more complex than mobileconfig style  As you can see in the template below, the `PayloadType` specifies Apple's managed client, which then parses the `PayloadContent` for the appropriate preference domain to control.   Additionally, CFPreferences have some additional flexibility over/above NSUserDefaults as they have a key which specifies "Forced" (always install, user can't change), or "Set-Once" (which means that the administrator wants to set the initial value but will allow the user to override.)

### Use this template as the basis for forming Custom XML to control NSUserDefaults preference domains:

```xml
    <dict>
        <key>PayloadUUID</key>
        <string>8-4-4-4-12-UUID-GENERATED-FROM-uuidgen</string>
        <key>PayloadType</key>
        <string>com.apple.ManagedClient.preferences</string>
        <key>PayloadOrganization</key>
        <string></string>
        <key>PayloadIdentifier</key>
        <string>CFPREFS.domain.8-4-4-4-12-UUID-GENERATED-FROM-uuidgen</string>
        <key>PayloadDisplayName</key>
        <string>Custom - CFPREFSDOMAIN</string>
        <key>PayloadDescription</key>
        <string>DESCRIPTION</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
        <key>PayloadEnabled</key>
        <true/>
        <key>PayloadContent</key>
        <dict>
            <key>CFPREFSDOMAIN</key>
            <dict>
            <key>Forced</key>
            <array>
                <dict>
                <key>mcx_preference_settings</key>
                <dict>
                    <key>BOOLEAN-KEY</key>
                    <true />
                    <key>INTEGER-KEY</key>
                    <int>1</int>
                    <key>STRING-KEY</key>
                    <string>StringValue</string>
                </dict>
                </dict>
            </array>
            </dict>
        </dict>
    </dict>
```

In the template, you must modify:
* The `PayloadUUID` string value which you can generate by running `uuidgen` in terminal
* The `PayloadDisplayName` string value
* The `PayloadIdentifier` string value which is a combination of the Preference Domain and a UUID
  * Note the preference domain will also be needed in the `Payload Content` section.
* The `PayloadType` string which is the preference domain read/written by the app (such as com.google.chrome or com.apple.touchidpolicy)
* The `Payload Description` to descript exactly what this Custom XML does.
* The CFPrefsDomain key should be the actual domain you're attempting to affect with the settings in your profile.
* The `<key>` and value (`<string>`, boolean, `<integer>`) and arrays which comprise the preference settings.   

## More Information ##
* For more information on how to build custom XML, check out [VMware AirWatch 101: XML Preferences for macOS Custom Settings Profile](https://blogs.vmware.com/euc/2017/06/xml-preferences.html)
* [CFPreferences Documentation [Apple]](https://developer.apple.com/documentation/corefoundation/preferences_utilities)
* [NSUserDefaults Documentation [Apple]](https://developer.apple.com/documentation/foundation/nsuserdefaults)