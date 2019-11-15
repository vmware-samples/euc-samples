## Notifications Custom XML for macOS ##

Use this to pre-stage allowed notifications for Corporate standard apps and/or automation tools (such as Intelligent Hub when using HubCLI for notifications).  Per [Apple's Developer Documentation](https://developer.apple.com/documentation/devicemanagement/notifications/notificationsettingsitem?changes=latest_minor), you'll need to mind the Alert Type:

* 0: None
* 1: Banner
* 2: Modal (e.g. "Alerts")

> This should be published as a Custom Settings payload in a macOS User profile.


```XML
<dict>
    <key>NotificationSettings</key>
    <array>
        <dict>
            <key>AlertType</key>
            <integer>2</integer>
            <key>BadgesEnabled</key>
            <true/>
            <key>BundleIdentifier</key>
            <string>com.airwatch.mac.agent</string>
            <key>CriticalAlertEnabled</key>
            <true/>
            <key>GroupingType</key>
            <integer>0</integer>
            <key>NotificationsEnabled</key>
            <true/>
            <key>ShowInLockScreen</key>
            <true/>
            <key>ShowInNotificationCenter</key>
            <true/>
            <key>SoundsEnabled</key>
            <true/>
        </dict>
    </array>
    <key>PayloadDescription</key>
    <string>Configures notifications settings.</string>
    <key>PayloadDisplayName</key>
    <string>Notification Settings</string>
    <key>PayloadIdentifier</key>
    <string>com.apple.notificationsettings.ABE75EA9-C93C-4F5F-A66D-36B851CC2635</string>
    <key>PayloadType</key>
    <string>com.apple.notificationsettings</string>
    <key>PayloadUUID</key>
    <string>ABE75EA9-C93C-4F5F-A66D-36B851CC2635</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
</dict>
```