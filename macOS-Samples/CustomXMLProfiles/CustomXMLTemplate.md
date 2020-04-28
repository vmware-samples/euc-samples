# Custom XML Payloads

MDM vendors can manage settings and preferences which are not included in the default Configuration Profile Reference via Custom Settings (or Custom XML) payloads.   A reverse-DNS style filename is written to one of a few handfuls of locations, depending on how a user or MDM sets the preferences:

- `/Library/Preferences/`
- `~/Library/Preferences/`
- `~/Library/Preferences/ByHost/`
- `~/Library/Preferences/<AppName>/`
- `/Library/Managed Preferences/`
- `/Library/Managed Preferences/<username>`

When reading and writing preferences, developers have two main frameworks/classes they can leverage:  NSUserDefaults and CFPreferences.

## Managing NSUserDefaults preferences

NSUserDefaults custom XML payloads tend to follow the mobileconfig style and are generally relatively flat.  As you can see in the template below, the `PayloadType` specifies the targeted set of user preferences, which are read/written by the application's NSUserDefaultsController.

Use this template as the basis for forming Custom XML to control NSUserDefaults preference domains:

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

- The `PayloadDisplayName` string value which is the user-friendly profile name displayed in the *Profiles* system preference pane
- The `PayloadIdentifier` string value which is a combination of the `PayloadType` Preference Domain and a UUID (example:  com.vendor.app.uuid)
- The `PayloadType` string which is the preference domain read/written by the app (such as com.google.chrome or com.apple.touchidpolicy)
- The `PayloadUUID` string value which you can generate by running `uuidgen` in Terminal.app in macOS
- The `<key>` and value (`<string>`, boolean, `<integer>`), and arrays which comprise the preference settings.

> When this profile is sent in the Device scope to the mdmclient, macOS generates a `PayloadType`.plist file in `/Library/Managed\ Preferences/`.  When this profile is sent in the User scope to the mdmclient, macOS generates a `PayloadType`.plist file in `/Library/Managed\ Preferences/{LoggedInUserName}`.

## Managing CFPreferences preferences

As you can see in the template below, CFPreferences profiles specify Apple's managed client the `PayloadType`.  This means the `PayloadContent` contains the appropriate preference domain to control.   Additionally, CFPreferences have some additional flexibility over/above NSUserDefaults as they have a key which specifies "Forced" (always install, user, can't change), or "Set-Once" (which means that the administrator wants to set the initial value but will allow the user to override.)

Use this template as the basis for forming Custom XML to control NSUserDefaults preference domains:

```xml
    <dict>
        <key>PayloadUUID</key>
        <string>8-4-4-4-12-UUID-GENERATED-FROM-uuidgen</string>
        <key>PayloadType</key>
        <string>com.apple.ManagedClient.preferences</string>
        <key>PayloadOrganization</key>
        <string>YourOrganizationname</string>
        <key>PayloadIdentifier</key>
        <string>CFPREFS.domain.8-4-4-4-12-UUID-GENERATED-FROM-uuidgen</string>
        <key>PayloadDisplayName</key>
        <string>Your User-Friendly Profile Display Name</string>
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

- The `PayloadUUID` string value which you can generate by running `uuidgen` in Terminal.app in macOS
- The `PayloadType` string *must* be **com.apple.ManagedClient.preferences**
- The `PayloadOrganization` is the organization name that displays in the *Profiles* system preference pane
- The `PayloadIdentifier` string value which is a combination of the CFPrefsDomain and a UUID
- The `PayloadDisplayName` string value which is the user-friendly profile name displayed in the *Profiles* system preference pane
- The `Payload Description` describes specifically what this Custom XML does for the user (e.g. how is this affecting their machine)
- PayloadContent Dictionary:
  - The `CFPREFSDOMAIN` key should be the actual app's preference domain you're attempting to affect with the settings in your profile
  - The `Forced` key ensures the user cannot modify the value.  Optionally, use the `Set-Once` value to enforce the values one time but allow the user to modify.
  - The `<key>` and value (`<string>`, boolean, `<integer>`), and arrays which comprise the preference settings.

> When this profile is sent in the Device scope to the mdmclient, macOS generates a `PayloadType`.plist file in `/Library/Managed\ Preferences/` and in `/Library/Managed\ Preferences/{LoggedInUserName}` at the same time.

## More Information

- For more information on how to build custom XML, check out [VMware AirWatch 101: XML Preferences for macOS Custom Settings Profile](https://blogs.vmware.com/euc/2017/06/xml-preferences.html)
- [CFPreferences Documentation [Apple]](https://developer.apple.com/documentation/corefoundation/preferences_utilities)
- [CFPreferences ManagedPreferences Payload Documentation [Apple]](https://developer.apple.com/documentation/devicemanagement/managedpreferences?changes=latest_minor)
- [NSUserDefaults Documentation [Apple]](https://developer.apple.com/documentation/foundation/nsuserdefaults)
