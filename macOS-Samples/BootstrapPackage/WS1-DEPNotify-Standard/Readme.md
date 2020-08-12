# Workspace ONE - DEPNotify Standard Deployment Package

### Overview
* Author: Paul Evans
* Email: pevans@vmware.com
* Date Created: 7/21/2019
* Supported Platforms: WS1 UEM 1907
* Tested on macOS Versions: macOS Mojave

This sample package can be used to easily set up a custom onboarding flow for new macOS devices in WS1 leveraging the [DEPNotify](https://gitlab.com/Mactroll/DEPNotify) app.  The package is customized to handle standard deployment flows where apps and packages are automatically deployed to devices through Workspace ONE.  The included signed .pkg build can be used as-is, and the flow can be customized using a "Custom Attributes" profile in the Workspace ONE UEM Console as shown in this document.

You can use the already built and signed WS1_DEPNotify_CustomNoAgent.pkg in the build folder, or further customize the onboarding experience by using this as a template to create your own Bootstrap Package that you will build and sign yourself.

A demo video is available of an onboarding flow that was built using the instructions below.  You can find it in the bin folder.

## Preparing the Workspace ONE UEM environment

* If you will be testing DEP enrollment, in the WS1 UEM Admin Console navigate to Settings > Devices & Users > Apple > Apple macOS > Intelligent Hub Settings.  Make sure that the option to "Install Hub after Enrollment" is Enabled.  The WS1 Hub is required to deploy software post-enrollment.

* Unless you are planning to enable Location Services on the device during the Setup Wizard (for DEP enrollment), or prior to normal enrollment, disable the collection of location data or else you will receive an additional prompt following enrollment. In the AirWatch Console, navigate to Settings > Devices & Users > Apple > Apple macOS > Intelligent Hub Settings.  Select Override and make sure that “Request to collect Location Data” is Disabled.

* Make sure macOS Software Management is enabled.  Navigate to Settings > Devices & Users > Apple > Apple macOS > Software Management.  Select Override and make sure “Enable Software Management” is enabled.

## Uploading the Bootstrap Package

1. In the AirWatch Console, navigate to Apps & Books > Applications > Native.
2. Make sure Internal is selected and select Add Application.
3. Upload the WS1_DEPNotify_CustomNoAgent.pkg file and select Save.
4. Select Continue.
5. If you don't have it already, download and install the VMware AirWatch Assistant for macOS, this will be used in the following section.
6. For the Deployment Type select Expedited Delivery.
7. Select Continue.
8. Select Save & Assign.
9. Select Add Assignment.
10. Choose the appropriate Assignment Groups.  Set App Delivery Method to Auto.
11. Select Add.
12. Select Save & Publish.
13. Select Publish.

## Preparing the Other Apps

1. This Bootstrap Package is configured to deploy multiple applications (.dmg, .pkg, .mpkg, or .app) in addition to itself.
2. Choose any applications that you want to demo and download them onto your computer.
3. Open the VMWare AirWatch Admin Assistant for macOS on your computer.
4. Drag each application file from Finder into the Admin Assistant window.  After the application is processed, select Reveal in Finder.
5. Verify that in the VMware AirWatch Admin Assistant folder in Finder you have the app file, a .plist file, and (usually) an image file for the icon.
6. Repeat this process for all other applications.

## Configuring up the Other Apps in Workspace ONE UEM

1. In the AirWatch Console, navigate to Apps & Books > Applications > Native.
2. Make sure Internal is selected and select Add Application.
3. Upload one of the application files from the VMware AirWatch Admin Assistant folder and select Save.
4. Select Continue.
5. If you uploaded a .pkg file, make sure the Deployment Type is set to Software Distribution.
6. Upload the appropriate .plist file to the Metadata File field.
7. Select Continue.
8. Select the Images tab and upload the appropriate icon image file.
9. Select the Scripts tab.
10. In the Post Install Script section, enter in the following text.  The script referenced is included in the Bootstrap Package:   
 
  ```shell
  #!/bin/sh
  ./tmp/Workspace\ ONE/DEPNotify/DEPNotifyCompletionCheck.sh
  ```
  
11. Select Save & Assign.
12. Select Add Assignment.
13. Choose the appropriate Assignment Groups.  Set App Delivery Method to Auto.
14. Select Add.
15. Select Save & Publish.
16. Select Publish.
17. Repeat this process with the other apps you will be deploying.

## Customize the DEPNotify Settings

If you want to brand the DEPNotify splash screen, find a small, square-ish image to use as a company logo.  Preferably, keep the size less than 200x200 pixels or so.  On a Mac, use the following command to convert the file into a hexadecimal string.  Make sure the image.png points to your image.  Copy the (very long) string that is output, you will need it shortly.     

```shell
xxd -ps image.png 
```

1. Create a new macOS > Device Profile in the WS1 Administrator Console.
2. Name the profile “DEPNotify Config”
3. Assign this profile to your Organization Group or Smart Group
4. Add a “Custom Attributes” payload
5. Name the Custom Attribute “DEPNotifyConfig”
6. Paste the following script in the Script/Command section.  Note the five fields that may be modified:
 * The numberOfApps=4 field should reflect the total number of apps deployed in addition to DEPNotify
 * The hexData="…" field should be updated to include the hex data from your chosen logo image file from step 1.  Make sure the quotes are included in this line, and that the entire data string is replaced.  Note that, depending on the size of the image file, this line may be very long.
 * BOTH /tmp/Workspace ONE/DEPNotify/newlogo.png lines should have the filetype changed to match the filetype of the original logo image (ie: png, jpg, etc).
 * The "Command: Main Text" line that will set up the main text displayed in DEPNotify throughout the onboarding process.
 * The "Status:" line will set up the initial status message displayed before the apps start downloading.
 * Note: removing the "Command: Image:" line will have DEPNotify use a default WS1 logo.   

  ```shell
  #!/bin/sh
  
  numberOfApps=4
  
  hexData="89504e470d0a1a0a0000000d49484452000000d2000000ca0806000000d0
  1c1eb4000000017352474200aece1ce9000000097048597300000b130000
  ...
  ...
  ...
  99342af20ba2bd718c110539e9e2d286fc8f9696970f202e26373638f350
  49dfff0fca6e42415bdcffb40000000049454e44ae426082"

  echo "$hexData" | xxd -r -p > "/tmp/Workspace ONE/DEPNotify/newlogo.png"
  
  notifylog="/private/var/tmp/depnotify.log"
  touch $notifylog
  chmod 777 $notifylog
  let a=$numberOfApps*2+2
  
  echo "Command: Image: /tmp/Workspace ONE/DEPNotify/newlogo.png" >> $notifylog
  echo "Command: Determinate: $a" >> $notifylog
  echo "Command: MainText: Thank you for enrolling your Mac!  Please be patient while your applications are installed.  This may take several minutes." >> $notifylog
  echo "Status: Configuring Device and Checking for Software..." >> $notifylog
  
  chmod 777 "/tmp/Workspace ONE/DEPNotify/DEPNotifyTotalSteps.txt"
  echo "$numberOfApps" > "/tmp/Workspace ONE/DEPNotify/DEPNotifyTotalSteps.txt"
  echo "Success"
  ```

7. Select Save and Publish.
8. Select Publish.

## Enroll your Device

Once all the apps are uploaded and configured, you are ready to enroll a test device.  Make sure an AirWatch Enrollment User is created and has the Enrollment Organization Group set to the Organization Group where you have configured this demo. 

If you are enrolling a DEP device, factory reset it to return it to the Setup Wizard.  The DEPNotify bootstrap package should deploy as soon as the user is logged in after the Setup Wizard.  For normal enrollment, download and install the AirWatch Agent manually, and then enroll your device through the AirWatch Agent.  The DEPNotify bootstrap package should deploy soon after enrollment is complete. 

After enrollment is complete, your device will download and install the applications that you configured in the AirWatch Console.  The DEPNotify splash screen will update the status each time an application file is downloaded, as well as when each application installs.   

Note:  When DEPNotify first launches, you will see a message indicating that custom settings are being initialized, and this may take 1-2 minutes.  This step is required to initialize the WS1 Hub and to apply the Custom Settings profile configured above.  In a production environment, this step would not be necessary as the Bootstrap Package would be directly built with the appropriate settings.

![DEPNotify_WS1_initialize.png?raw=true](/macOS-Samples/BootstrapPackage/WS1-DEPNotify-Standard/bin/DEPNotify_WS1_initialize.png)

When all applications are installed, the DEPNotify window should update with an alert showing that the device is configured and give the user the option to close the window.

## Extra: Updating the macOS Dock as your Apps Install

If your macOS deployment includes deploying a Dock profile to devices, you can use the killall Dock command in the Post Install Script section of the AirWatch configuration for your applications.  This will cause the Dock to reload and will now show the installed app's icon (as long as your Dock profile is adding these apps to the user's Dock).

1. Create a Dock profile.  In the AirWatch Console navigate to Devices > Profiles & Resources > Profiles and select Add, and then Add Profile.
2. Select your platform as Apple macOS.
3. Select User Profile or Device Profile.
4. Select the Dock payload on the left.
5. Select the Items tab.  Add each application to the Application Path section.  Note that you should configure the path to each installed application.
6. Under the Options tab, you can enable or disable the Merge with User's Dock option.  This will determine if your apps will be appended to the existing Dock, or if your configured Application Path apps will replace the existing Dock entirely.
7. Update the Post Install Script section of each application to include the killall Dock command.  Each time an app is installed, the Dock will automatically refresh to show that app's installed state.  The full section should be as follows, unless you are doing any additional scripting:

  ```shell
  #!/bin/sh
  ./tmp/Workspace\ ONE/DEPNotify/DEPNotifyCompletionCheck.sh 
  killall Dock
  ```


