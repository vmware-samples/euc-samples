# Configure Screen Saver on macOS

### Overview
* Author: Paul Evans
* Email: pevans@vmware.com
* Date Created: 7/25/2018
* Supported Platforms: WS1 UEM 1907
* Tested on macOS Versions: macOS High Sierra


More granular configuration of screen saver settings can be done on macOS through scripting.  This script can be setup as a login script, which will reapply every time the end user logs into their device.  Alternatively, if you are looking to deploy one or more images to the device to configure as the screen saver, you can create a PKG file that will deploy the files and apply the configuration all in one go.

## Deploy Screen Saver as a PKG
After navigating to the project directory, you can build the SetScreenSaver PKG with the following command:

```bash
pkgbuild --install-location / --identifier "com.WorkspaceONE.SetScreenSaver" --version "1.0" --root ./payload/ --scripts ./scripts/ ./build/SetScreenSaver.pkg
```

This will create a PKG that does two things when installed:

1. Copies all files located in the payload folder onto the client machine, in the same folder structure.  For example, the files located in "./payload/Library/Screen Savers/WS1" within the PKG will be copied to the client machine to "/Library/Screen Savers/WS1"
2. Run the "postinstall" script located within the "./scripts/" folder.

By copying one or more image files into the appropriate payload folder, you can deploy your image files to the target machine.

Once the PKG has been built, you can deploy it as an Internal app through the Workspace ONE UEM Admin Console.  Use the VMware Admin Assistant Tool to create the necessary plist file, and then upload and assign to devices in the Admin Console.  Example SetScreenSaverImage and SetScreenSaverMessage PKG and plist files have been included in the build folder.

## Configure the Screen Saver to Cycle Through Images

The current postinstall script is set up to configure the screen saver to cycle through the provided images in a random order (if more than one are provided).  The postinstall script can be modified as necessary to update the configuration.  Some specific values to pay attention to:

* Change the SelectedFolderPath to where your image files are stored.
* Change ShufflesPhotos to 0 for the images to be cycled through in sequential order.
* Change the idleTime to the time period to wait before the screen saver is triggered (in seconds).
* Change showClock to 0 if you do not want to display the clock within the screen saver.

```bash
#!/bin/bash
currentUser=`ls -l /dev/console | awk {' print $3 '}`

su $currentUser -c '/usr/bin/defaults -currentHost write com.apple.screensaver moduleDict -dict moduleName "iLifeSlideshows" path "/System/Library/Frameworks/ScreenSaver.framework/Resources/iLifeSlideshows.saver" type 0'
su $currentUser -c '/usr/bin/defaults -currentHost write com.apple.screensaver.iLifeSlideShows styleKey Classic'

su $currentUser -c '/usr/bin/defaults -currentHost write com.apple.screensaverphotochooser SelectedFolderPath "/Library/Screen Savers/WS1"'
su $currentUser -c '/usr/bin/defaults -currentHost write com.apple.screensaverphotochooser LastViewedPhotoPath ""'
su $currentUser -c '/usr/bin/defaults -currentHost write com.apple.screensaverphotochooser ShufflesPhotos 1'

su $currentUser -c '/usr/bin/defaults -currentHost write com.apple.screensaver idleTime -int 300'
su $currentUser -c '/usr/bin/defaults -currentHost write com.apple.screensaver showClock 1'

killall cfprefsd

echo "Success"
```

## Configure the Screen Saver to Display a Message

If you want the device to display a standard message as a screen saver, instead of an image, this can be configured as well with the following postinstall script.  Note that you can update the Message, idleTime, and showClock fields similar to the example above.

```bash
#!/bin/bash
currentUser=`ls -l /dev/console | awk {' print $3 '}`

su $currentUser -c '/usr/bin/defaults -currentHost write com.apple.screensaver moduleDict -dict moduleName "Message" path "/System/Library/Frameworks/ScreenSaver.framework/Resources/Computer Name.saver" type 0'

su $currentUser -c '/usr/bin/defaults -currentHost write com.apple.screensaver.basic MESSAGE "This is my test message."'

su $currentUser -c '/usr/bin/defaults -currentHost write com.apple.screensaver idleTime -int 300'
su $currentUser -c '/usr/bin/defaults -currentHost write com.apple.screensaver showClock 1'

killall cfprefsd

echo "Success"
```

## Reapply the Screen Saver Configuration on User Login
If the end user has access to the Screen Saver configuration within the System Preferences menu, they will be able to change the screen saver configuration from the device even if it initially set during the installation of a PKG file.  However, you can reapply the specified configuration at user login by creating and deploying a Custom Attributes profile in WS1:

1. Create a new macOS > Device Profile in the WS1 Administrator Console
2. Name the profile “Screen Saver - Login Script”
3. Assign this profile to your Organization Group or Smart Group
4. Add a “Custom Attributes” payload
5. Name the Custom Attribute “ScreenSaver”
6. Paste the postinstall script in the Script/Command section
7. Change Execution Interval to "Event"
8. Add "Login" as an Event Type
9. Select Save and Publish
10. Select Publish