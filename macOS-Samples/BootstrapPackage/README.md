# Bootstrap Package

<img src="https://raw.githubusercontent.com/vmwaresamples/AirWatch-samples/master/macOS-Samples/BootstrapPackage/images/Bootstrap_icon_400px.png" style="width: 200px;"/>

The Bootstrap Package feature gives admins the ability to have their installer pkgs deployed to devices *immediately* after enrollment has completed.

Without using Bootstrap, the AirWatch Agent must be installed first, and the Agent handles the installer pkgs. However, sometimes this process is too slow and happens several minutes after enrollment completes, which can cause problems if the user begins to use the machine before all software and tools are installed & configured. With this feature, Admins can have peace of mind that their installer pkgs are deployed as soon as technically possible.

## Who is this feature for?
Some admins might want to use some alternative tools to handle the majority of the management tasks, in addition to the AirWatch Agent. Additionally, many IT departments use imaging to provision devices with software before distributing to employees. With this feature, they can perform a DEP enrollment, then deploy a 'bootstrap' package that installs their tooling and configures the device.

The feature is best paired with a DEP Enrollment, but is available for all types of enrollments - Agent, Web, and DEP.

#### Common Uses Cases:
* Admin wants to use Munki for Application Management. The Munki client needs to be installed right after enrollment so the user can begin installing apps, rather than going through the AirWatch Agent + App Catalog.
* Admin only uses MDM for certificate management, security, and some software management, but uses Chef or Puppet for configuration management. They want Chef/Puppet installed instantly when enrollment completes, to start configuring the machine before the user starts to use it.
* Admin wants to create a custom branded end-user experience (see DEPNotify or SplashBuddy) that launches a window as soon as enrollment completes, to let the user know what's happening and to hold off using the machine until it's done downloading and provisioning.
* Admin doesn't want to deploy AirWatch Agent, but still needs some critical software to be deployed to devices.

## How does it work?
This feature leverages an Apple MDM Command called `InstallApplication`. This [Apple API command](https://developer.apple.com/library/content/documentation/Miscellaneous/Reference/MobileDeviceManagementProtocolRef/3-MDM_Protocol/MDM_Protocol.html#//apple_ref/doc/uid/TP40017387-CH3-SW755) allows an MDM provider to natively install signed .pkgs to an enrolled device. Historically, to install .pkgs the AirWatch Agent would handle the download and installation. This is usually fine for the majority of pkgs (productivity apps), but for those pkgs in which the Admin needs installed ASAP after enrollment, using a bootstrap package is more appropriate

[Please be sure to read the Caveats!](https://github.com/vmwaresamples/AirWatch-samples/tree/master/macOS-Samples/BootstrapPackage#caveats)

##### Before Bootstrap
[<img src="https://raw.githubusercontent.com/vmwaresamples/AirWatch-samples/master/macOS-Samples/BootstrapPackage/images/Pre-Bootstrap.png">](https://raw.githubusercontent.com/vmwaresamples/AirWatch-samples/master/macOS-Samples/BootstrapPackage/images/Pre-Bootstrap.png)

##### With Bootstrap
[<img src="https://raw.githubusercontent.com/vmwaresamples/AirWatch-samples/master/macOS-Samples/BootstrapPackage/images/With_Bootstrapedit.png">](https://raw.githubusercontent.com/vmwaresamples/AirWatch-samples/master/macOS-Samples/BootstrapPackage/images/With_Bootstrapedit.png)


##### Apple MDM API InstallApplication Command
[<img src="https://raw.githubusercontent.com/vmwaresamples/AirWatch-samples/master/macOS-Samples/BootstrapPackage/images/MDMInstallApplicationFlow.png">](https://raw.githubusercontent.com/vmwaresamples/AirWatch-samples/master/macOS-Samples/BootstrapPackage/images/MDMInstallApplicationFlow.png)


## When does it install?
The Bootstrap package is deployed to the device *as soon as enrollment completes*. It will only deploy right after enrollment, or if initiated "On-Demand" via the Console UI or API. **It will not deploy to existing enrolled devices, unless specifically queued on-demand via Console or API.**

Below are links to detailed flow charts for each enrollment flow, showing when the `InstallApplication` command is queued:

* [DEP Enrollment Flow](https://raw.githubusercontent.com/vmwaresamples/AirWatch-samples/master/macOS-Samples/BootstrapPackage/images/DEP_Bootstrap.png)
* [Agent Enrollment Flow](https://raw.githubusercontent.com/vmwaresamples/AirWatch-samples/master/macOS-Samples/BootstrapPackage/images/AgentEnrollment_Bootstrap.png)
* [Web-Enrollment/Sideload Enrollment Flow](https://raw.githubusercontent.com/vmwaresamples/AirWatch-samples/master/macOS-Samples/BootstrapPackage/images/WebEnrollment_Bootstrap.png)

Once `InstallApplication` is acknowledged, the install will happen depending on download speed + install time. But as diagrammed in the [above InstallApplication flowchart](https://raw.githubusercontent.com/vmwaresamples/AirWatch-samples/master/macOS-Samples/BootstrapPackage/images/MDMInstallApplicationFlow.png), the `mdmclient` does not tell the server when the pkg is installed. So we do not have any visibility on the download or install status - we can only display when the command was queued and acknowledged.

**Note:** Device-Context profiles will be queued before Bootstrap. So, for example, if your package depends on a certificate, it should be installed via profile so that it's available when the package is installed.


## Package Requirements

There are several tools that can assist in creating a package for use in this feature. But regardless of how the package is created, there are two basic requirements:

* Package must be **signed** with an appropriate certificate (such as a TLS/SSL certificate with signing usage). Only the package needs to be signed, not the app; Apple’s Gatekeeper doesn’t check apps installed through MDM.
	* Most 3rd Party packages are already signed. For custom packages, we recommend using an Apple Developer Signing Certificate for macOS.
* Package must be a **distribution pkg** (product archive), not a flat component pkg

**Recommended Package Creation Tools:**

* Native CLI tools - [pkgbuild](https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/pkgbuild.1.html) + [productbuild](https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/productbuild.1.html) (example below)
* Munkipkg (does not require Munki)
* Packages

[**Example: Building a simple custom UI package with DEPNotify**](https://github.com/vmwaresamples/AirWatch-samples/tree/master/macOS-Samples/BootstrapPackage/Example-DEPNotify)

[**Example: Building a simple package to set the wallpaper**](https://github.com/vmwaresamples/AirWatch-samples/tree/master/macOS-Samples/BootstrapPackage/Example-SetWallpaper)  

[**Recommended Deployment - InstallApplications Tool**](https://github.com/vmwaresamples/AirWatch-samples/tree/master/macOS-Samples/BootstrapPackage#recommended-deployment---installapplications-tool)

## Setup via AirWatch Console
This feature has been added to the UI where Internal Apps currently reside

1. Navigate to **Apps & Books > Internal > Add Application**
2. Upload a .pkg that meets the below requirements:
	* Package must be **signed** with an appropriate certificate (such as a TLS/SSL certificate with signing usage). Only the package needs to be signed, not the app; Apple’s Gatekeeper doesn’t check apps installed through MDM.
	* Package must be a **distribution pkg** (product archive), not a flat component pkg
3. Click **Continue** and modify the fields in the *Details* and/or *Images* tabs if necessary
4. Click **Save & Assign** and **Add Assignment**
5. Assign a Smart Group and Deployment mode and **Save & Publish**


**App Delivery Method**  
By default this feature is set to **Auto**. **It will only install to newly enrolled devices**.  

If you want the package to be deployed to existing enrolled devices, navigate to the Application Details by clicking the package in the Internal Apps List view, then navigate to the Devices tab to select which devices to On Demand install.


If **On Demand** is selected, then it will only install to devices that have been selected to on-demand install from the Application Details > Devices tab. It will not automatically deploy to newly enrolled devices.  

In both cases, the package will not be published to an existing enrolled device unless specifically initiated via On Demand install via the Console.


## Troubleshooting
[Please be sure to read the Caveats!](https://github.com/vmwaresamples/AirWatch-samples/tree/master/macOS-Samples/BootstrapPackage#caveats)

If you are experiencing issues where it appears the package is not installing after enrollment, here are some things to check:

1. Check Device Details > Troubleshooting tab, did the command get queued and processed for the device?
	* Check the Event Log or Commands tab (use Filters)
2. If it did get queued and processed, grab a device that has enrolled and open Terminal.app
	* Enter `sudo log collect --output ~/Desktop`
	* Wait for the log to be generated
	* Enter `open ~/Desktop/system_logs.logarchive`
	* This will open the log in Console.app
	* In the top right Filter text box, type **Subsystem:com.apple.ManagedClient** and press Enter, then type **Subsystem:com.apple.Commerce** and press Enter again
		* Key log lines to look for for **Subsystem:com.apple.ManagedClient** (note timestamps):
			* *mdmclient    Processing server request: InstallApplication  for: \<Device>*
			* *mdmclient    Scheduled InstallApplication from: https://{env-url}/DeviceServices/secure/{hash}/Manifest.plist*
		* Key log lines to look for for **Subsystem:com.apple.Commerce** (note timestamps):
			* *storedownloadd    DownloadManifest: removePurgeablePath: /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/C/com.apple.appstore/0*
			* *storedownloadd    sending status (DEPNotify): 0.000000% (0.000000)*
				* DEPNotify would be replaced with the name of your package
			* *storedownloadd    ISStoreURLOperation: Starting URL operation with url=\<long-url> / bagKey=(null)*
			* *storedownloadd    \<HashedDownloadProvider: 0x7fd025c271a0>: Opening file /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/C/com.apple.appstore/0/ecd16ca5-7456-4a13-9970-75dfe7ff7a85.pkg returning file descriptor 3 (0 streamed)*
			* *storedownloadd    sending status (DEPNotify): 0.806452% (8.000000)*
				* DEPNotify would be replaced with the name of your package
			* *storedownloadd    installClientDidBegin*
	* If you get to this point and see the line *installClientDidBegin*, and the pkg still did not install, it's time to open the `/var/log/install.log` to see where the installation failed
		* In Terminal, enter `open /var/log/install.log`
		* Use the timestamp for *storedownloadd installClientDidBegin* and start reading install.log from around that time to trace the installation process
3. If the Console shows the command did not get queued and/or processed (step 1), then open a Support Ticket so that an agent can help troubleshoot via the Server


## Caveats
The reason this command has not been implemented until now is due a few historical platform issues and limitations

However, when used correctly with 10.12.6+, it has shown to be reliable enough for us to implement it for customers to use, but with a few known caveats stated:

* This MDM command is designed for .pkg only
	* An .app file should be bundled in a .pkg if the admin wants to deploy using this method
* The Console will only show the status of the command. But will not be able to show download or install statuses. [*Please see the "How does it work?" section for the command for more details.*](https://github.com/vmwaresamples/AirWatch-samples/tree/master/macOS-Samples/BootstrapPackage#installapplication-command)
* From 10.9 to 10.12.5, only one `InstallApplication` command may be sent at a time. If multiple are sent around the same time, the commands will be `Acknowledged`, but only 1 will download and install, or none will at all - the behavior is inconsistent. This is an Apple Bug that has been fixed in 10.12.6 and 10.13+. The server will not have visibility of the download/install statuses so particular is tricky to troubleshoot without having a device in-hand.
	* Pre-10.12.6 devices will run into this issue if they are assigned a Bootstrap pkg and also the AirWatch Console Setting is enabled to install Agent after enrollment (Settings > Devices & Users > Apple > Apple macOS > Agent Application). To workaround this, we advise turning off the Agent setting, and using a tool such as [InstallApplications](https://github.com/erikng/installapplications), to install+download both the desired Bootstrap pkg and the Agent.
* The Bootstrap pkg cannot be "removed" once installed. Admins will need to create an additional uninstaller script or pkg if this needs to be done.


## Recommended Deployment - InstallApplications Tool
To have greater control over what packages are installed on enrollment, and also to work around Apple bugs on pre-10.12.6 devices, we advise using the open source tool, [InstallApplications](https://github.com/erikng/installapplications). This tool was created *specifically for this feature*, to enhance the capabilities of `InstallApplication` and work around the OS platform issues & limitations.

#### How does the tool work?  
Pkgs are stored on an external file server, such as AWS S3. A JSON Manifest should be created that defines the location, name, and SHA256 hash of each file and also stored on a file server. The InstallApplications tool will look at this manifest to download and install the packages in the defined order, validating the hash before installation for security.  

[<img src="https://raw.githubusercontent.com/vmwaresamples/AirWatch-samples/master/macOS-Samples/BootstrapPackage/images/InstallApplications%20Tool.png">](https://raw.githubusercontent.com/vmwaresamples/AirWatch-samples/master/macOS-Samples/BootstrapPackage/images/InstallApplications%20Tool.png)

#### Why should I use this tool?  
Due to the caveats and limitations stated above, this tool extends the Bootstrap feature to give the admin more control over when the packages are deployed and in what order they are installed.

1. The tool handles installing packages during Setup Assistant in a DEP enrollment during "PreStage". Packages defined in "Stage 1" or "Stage 2" will not install until a user session is active. This allows the admin to install critical tools first, before the user even gets to the desktop, then install user-context tools and UI windows once the user is in their session. With this model of deployment, the admin can create any custom installation deployment flow they want.
2. The InstallApplications tool also provides detailed verbose logging that can be used for troubleshooting issues with individual installer packages. Native MDMClient logging is sparse and is harder to sift through when issues arise (see [Troubleshooting section](https://github.com/vmwaresamples/AirWatch-samples/tree/master/macOS-Samples/BootstrapPackage#troubleshooting)).
3. For Mac fleets that are not all updated to 10.12.6+, and the admin wants to push Bootstrap + AirWatch Agent on enrollment, this tool will be required to ensure all packages install (see [Caveats](https://github.com/vmwaresamples/AirWatch-samples/tree/master/macOS-Samples/BootstrapPackage#caveats))
4. The Admin wants to use DEP+Bootstrap to replace their imaging workflow to provision devices with multiple softwares automatically


#### Troubleshooting InstallApplications Tool  
Grab a device that has enrolled and open Terminal.app

1. Enter `sudo log collect --output ~/Desktop`
	* Wait for the log to be generated
2. Enter `open ~/Desktop/system_logs.logarchive`
	* This will open the log in Console.app
3. In the top right Filter text box, type `[InstallApplications]` and press Enter  


The logs are verbose and will show full download and installation statuses for each package

If there are no logs in the filter, then follow the steps in the main Troubleshooting section to verify the tool was downloaded and installed via `InstallApplication`
