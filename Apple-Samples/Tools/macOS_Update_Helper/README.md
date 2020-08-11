# macOS Update Helper

### Overview
* Author: Paul Evans
* Email: pevans@vmware.com
* Date Created: 5/19/2020
* Supported Platforms: WS1 UEM 2003
* Tested on macOS Versions: macOS Mojave -> macOS Catalina

This package can be used to provide more flexibility around deploying macOS updates to devices through Workspace ONE UEM, as well as to provide information and feedback to the user regarding the progress of the update.  The package can be customized through the use of a Custom Settings profile in Workspace ONE UEM.  It leverages [DEPNotify](https://gitlab.com/Mactroll/DEPNotify/blob/master/README.md) to act as a UI for the end user.

Currently, this process leverages the ```startosinstall``` command in order to download and initiate the macOS update, and can be used to update devices on versions prior to macOS Catalina.  However, in future versions i'll look to leverage the ```softwareupdate``` command introduced in Catalina to provide an alternate workflow to update to newer versions beyond Catalina.

The overall flow of the tool is as follows:

1. The "Install macOS {version}.app" application is deployed to the device, as well as the macOS Update Helper pkg.  The "Install macOS {version}.app" file can be deployed using the options outlined in [Managing Major OS Updates for Mac: VMware Workspace ONE Operational Tutorial](https://techzone.vmware.com/managing-major-os-updates-mac-vmware-workspace-one-operational-tutorial).  Alternately, this readme will include instructions on including the app as part of the macOS Update Helper pkg.

2. Administrators can allow users to defer the deployment of the update by specifying a number of deferrals allowed and/or a go-live date, after which the deployment will continue automatically.
![deferral_notification.png?raw=true](/macOS-Samples/Tools/macOS_Update_Helper/bin/deferral_notification.png)
3. Administrators can choose to instruct the user that the update is about to begin and give them an opportunity to prepare before actually starting.
![user_prep.png?raw=true](/macOS-Samples/Tools/macOS_Update_Helper/bin/user_prep.png)
4. Once the update begins, Administrators can choose whether to block their users from the Desktop until it is complete by setting the macOS Update Helper to fullscreen mode.  The macOS Update Helper will continue to keep the user informed as the update is downloaded, and when it will be restarting to install the update.  The ```startosinstall``` command will automatically restart the device after the download is complete.
![in_progress_fullscreen.png](/macOS-Samples/Tools/macOS_Update_Helper/bin/in_progress_fullscreen.png)

## macOS Update Helper Custom Settings

When deploying the macOS Update Helper to devices through Workspace ONE UEM, you should also create a profile with a Custom Settings payload to configure the appropriate settings.  Copy and paste the XML below into the Custom Settings payload, and update the settings as appropriate.


```
<dict>
	<key>PayloadUUID</key>
	<string>EAC58AF6-73A0-420A-946A-837CD2C61CDE</string>
	<key>PayloadType</key>
	<string>com.vmware.macosupdatehelper</string>
	<key>PayloadOrganization</key>
	<string>Workspace ONE</string>
	<key>PayloadIdentifier</key>
	<string>com.vmware.macosupdatehelper.EAC58AF6-73A0-420A-946A-837CD2C61CDE</string>
	<key>PayloadDisplayName</key>
	<string>macOS Update Helper Settings</string>
	<key>PayloadDescription</key>
	<string>macOS Update Helper Settings</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
	<key>PayloadEnabled</key>
	<true/>
	<key>macOSVersion</key>
	<string>10.15</string>
	<key>allowUserPrep</key>
	<true/>
	<key>allowDeferrals</key>
	<true />
	<key>notificationInterval</key>
	<integer>28800</integer>
	<key>goLiveDate</key>
	<string>2021.01.01</string>
	<key>deferralNotificationType</key>
	<string>goLiveDate</string>
	<key>fullScreenDownloader</key>
	<true />
	<key>updateIcon</key>
	<true />
	<key>iconURL</key>
	<string>https://test.image.com/image.png</string>
</dict>
```

| Key | Type | Default | Function |
|---|---|---| ---|
| macOSVersion | string | 10.15 | The version of macOS you are updating devices to. Example: 10.15 |
| allowUserPrep | bool | true | If true, will display a window to the user allowing them to prepare before beginning the update process.  This occurs after This is ignored if the goLiveDate has passed. |
| allowDeferrals | bool | false | If true, will allow the user to defer the update.  Should be used in conjunction with numberOfDeferrals and/or goLiveDate. |
| notificationInterval | integer | 28800 | The length of time (in seconds), between notifications.  Defaults to 8 hours. |
| numberOfDeferrals | integer | -1 | The number of deferrals allowed before automatically continuing the update process.  Note that allowUserPrep can still occur after the maximum number of deferrals. If set to -1, allows infinite deferrals.|
| goLiveDate | string | N/A | The date after which the update should be deployed automatically.  Bypasses allowUserPrep and numberOfDeferrals if needed.  Use the form "YYYY.mm.dd". Ignored if not specified. |
| deferralNotificationType | string | N/A | Formats the deferral notification shown to the user.  Should be "goLiveDate" ("You may defer until {goLiveDate}") or "numberOfDeferrals" ("You may defer X more times").  Ignored if not specified. |
| fullScreenDownloader | bool | false | After the update process begins (ie: step 4 outlined above), this will block the user from accessing their desktop while the macOS update is downloaded.  This can be used in conjunction with allowUserPrep (which will not be full-screened).  Otherwise, the UI will be displayed in a normal windowed form. |
| updateIcon | bool | false | Allows you to override the icon used in the UI.  Use in conjunction with iconURL. |
| iconURL | string | N/A | A direct URL to the image you use to replace the default icon in the UI. |

## How to build the macOS Update Helper pkg

1. Download the full project folder from github.
2. In Terminal, navigate to the downloaded directory on your local machine.
3. Run the following command: ```./buildpkg```
4. Enter your local administrator password when prompted.
5. In the ```build``` folder, this will create a .pkg and .plist file that you can use to upload to Workspace ONE UEM.

## How to include the "Install macOS X.app" with macOS Update Helper

1. Download the "Install macOS X.app" file using one of the processes outlined in [Managing Major OS Updates for Mac: VMware Workspace ONE Operational Tutorial](https://techzone.vmware.com/managing-major-os-updates-mac-vmware-workspace-one-operational-tutorial).
2. Copy the .app file into the ```./payload/Applications/``` folder of the project.
3. Build the pkg as outlined above.