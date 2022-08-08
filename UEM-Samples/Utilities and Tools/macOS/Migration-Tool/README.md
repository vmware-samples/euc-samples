# Migrate macOS Devices to Workspace ONE UEM

This is an updated version of the previous generation of the tool which can be found [here]().

This tool is designed to be flexible to fit different use cases. There is no default mode, so you must understand how the tool works in order to configure it for your needs.

This tool is designed to work with DEPNotify for an easy-to-configure UI. Understanding the many capabilities of DEPNotify and how to configure it is highly recommended to create a great migration experience.

-------------------------------------------------------------------

To use this tool, you must first make some decisions on how the migration and enrollment experience should be. 


## What do you want the experience to be?
1. **I want it completely silent and transparent to the end user.**
	* Unfortunately this is not really a viable option anymore. Since macOS 10.13.4, some critical functionality in MDM requires User Approved MDM Enrollment such as installing Kernel Extension whitelists or Privacy Preference policies.

2. **I want minimal user interaction and visuals, just enough for User Approved MDM Enrollment.**
	* Typically this means you will not require users to do any form of enrollment authentication to complete the migration.

3. **I dont need my users to do anything special, but I want them to have a great visual experience throughout the migration to explain the process and tell them when it's finished.**
	* This is the most typical migration we see, the evolution of #2, which balances complexity with a good UX, while also ensuring the enrollment is User Approved.

	
-------------------------------------------------------------------

## How does this tool work?
This tool is a collection of files and scripts distributed to targeted devices as a .pkg file. The assumption is that you use the prior MDM to install this .pkg or alternatively it is manually installed by a user.

As soon as the .pkg is installed, the following will happen:
1. Migrator (this tool) will install and load its Launch Daemon
2. The Launch Daemon will execute the migration script along with your configured parameters.
3. The migration script will run in a defined order, behaving as you configure it, removing the prior MDM and then guiding the installation of Workspace ONE.
4. Migrator will gracefully exit and kill its process.

## Configuration
There are 3 main steps to obtain a pkg that you are able to deploy:
1. [Launch Daemon Configuration](#launch-daemon)
2. [Customization Scripts](#customization-scripts) (optional)
3. [Building the pkg](#building-the-pkg)

### Launch Daemon

This tool installs a launchdaemon that executes a bash script to perform the migration. The script comes with a number of flags and keys to define the behavior depending on use case. Here are the flags that are configured and their meaning. Below you will find a couple of [examples](#example-configurations-launch-daemon) of how you might configure the flags. 
| Flag Name | Required? | Example | Details |
|---|---|---| ---|
| --origin | Yes | Must be set to wsone or custom | Tells the tool what the source MDM envrionment will be |
| --origin-apiurl | Yes, if origin = wsone | https://as1380.awmdm.com | The WS1 API URL of source environment |
| --origin-auth | Yes, if origin = wsone | Basic ABCD1234WXYZ9876==  | Base64 encoded API credentials for the source WS1 tenant |
| --origin-token | Yes, if origin = wsone | ABCDEFG1234567+COJnXFNZM6uZxXLVVTAUuUheXI= | REST API token for the source WS1 tenant |
| --removal-script | Yes, if origin = custom and different than example | /Library/Application Support/VMware/MigratorResources/removemdm.sh | Full absolute path of the script containing the steps to remove the prior MDM. You can put this script wherever you want, but it's recommended to use the same directory as in the example |
| --enrollment-profile-path | Yes if different than example | /Library/Application Support/VMware/MigratorResources/enroll.mobileconfig | Full absolute path of the mobileconfig file that is used to enroll device to destination WS1 tenant. |
| --registration-type | Yes if different than 'none' | local, prompt or none | The method used to retrieve username of the Mac being migrated. More details [here](#registration-types) |
| --dest-baseurl | Yes if registration-type is not 'none' | https://ds1688.awmdm.com | The WS1 Device Services URL of destination environment |
| --dest-auth | Yes if registration-type is not 'none' | Basic ABCD1234WXYZ9876== | Base64 encoded API credentials for the destination WS1 tenant |
| --dest-token | Yes if registration-type is not 'none' | ABCDEFG1234567+COJnXFNZM6uZxXLVVTAUuUheXI= | REST API token for the destination WS1 tenant |
| --dest-groupid | Yes if registration-type is not 'none' | Group1234 | Group ID of target Organization Group in destination environment |
| --dest-apiURL | Yes if registration-type is not 'none' | https://as1688.awmdm.com | The WS1 API URL of destination environment  |
| --user-prompt | Yes if registration-type set to 'prompt' | username or email | What value to request from the user during migration in order to find their user account in destination WS1 tenant |

#### Registration Types
In order to ensure the device is enrolled to the proper user in the destination Workspace ONE environment, there are 3 registration modes. It is important that regardless of mode used, there must be a match for the valid username in the destination environment: 
1. local
	- This will use the username of the local macOS user account to register the device to in Workspace ONE. 
2. prompt
	- This will prompt the user to provide their username (or email address) during the migration process
	- When using this option be sure to also use `--user-prompt` to set what value to request from the user (username or email)
3. none
	- No registration will happen as part of migration process. Use this method if you plan to preregister devices to users in Workspace ONE using a CSV [batch import](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/UEM_ConsoleBasics/GUID-AWT-BATCHIMPORTFEATURE.html). 

#### Example Configurations (Launch Daemon)
Custom (other MDM provider) to Workspace ONE with local username used to register the device to the user in WS1:
```
<key>ProgramArguments</key>
<array>
	<string>/bin/bash</string>
	<string>/Library/Application Support/VMware/migrator.sh</string>
	<string>--origin</string>
	<string>custom</string>
	<string>--removal-script</string>
	<string>/Library/Application Support/VMware/MigratorResources/removemdm.sh</string>
	<string>--registration-type</string>
	<string>local</string>
	<string>--dest-baseurl</string>
	<string>https://ds1380.awmdm.com</string>
	<string>--dest-auth</string>
	<string>Basic YWlyd2F0Y2hcbXphc2tlOmlka1dURjY5OCQjYmlneg==</string>
	<string>--dest-token</string>
	<string>u6eL5iq92WZBM8nP+COJnXFNZM6uZxXLVVTAUuUheXI=</string>
	<string>--dest-groupid</string>
	<string>mz</string>
	<string>--dest-apiurl</string>
	<string>https://as1380.awmdm.com</string>
</array>
```

Workspace ONE to Workspace ONE with no registration:
```
<key>ProgramArguments</key>
<array>
	<string>/bin/bash</string>
	<string>/Library/Application Support/VMware/migrator.sh</string>
	<string>--origin</string>
	<string>wsone</string>
	<string>--origin-apiurl</string>
	<string>https://as1688.awmdm.com</string>
	<string>--origin-auth</string>
	<string>Basic YWlyd2F0Y2hcbXphc2tlOmlka1dURjY5OCQjYmlneg==</string>
	<string>--origin-token</string>
	<string>u6eL5iq92WZBM8nP+COJnXFNZM6uZxXLVVTAUuUheXI=</string>
	<string>--registration-type</string>
	<string>none</string>
</array>
```

### Customization Scripts

The tool can also be further customized through the use of add-on scripts. You will find these scripts within the `payload` directory and below are quick definitions of how they might be used if you choose to do so. These are not required for the tool to function, but give flexibility to add to user experience or handle any other tasks. These scripts must belong at the designated path in the chart. 
| Name | Purpose | Path |
|---|---|---|
| Pre-DEPNotify | Script to run before DEPNotify is opened. This is where you should add all DEPNotify customizations like branding and content. | /Library/Application Support/VMware/MigratorResources/predepnotify.sh |
| Pre-Migration | Script to run after DEPNotify has opened, but right before the Origin MDM removal step is performed. This is where you should add DEPNotify customizations that should occur before the migration begins. | /Library/Application Support/VMware/MigratorResources/premigration.sh |
| Mid-Migration | Script to run after the origin MDM has been removed but before starting the process of obtaining & installing the destination MDM profile. This is where you should add DEPNotify customizations (like progress indicators to the user). | /Library/Application Support/VMware/MigratorResources/midmigration.sh |
| Post-Migration | Script to run after destination MDM profile has been installed. This is where you should add final DEPNotify customizations and inform the user of the migration completion. | /Library/Application Support/VMware/MigratorResources/postmigration.sh |

### Building the pkg
1. Download the files needed to build the pkg by clicking the zip file at the top of this page `migrationToolWS1.zip` and then selecting "Download" option
2. Make any edits needed such as:
	1. Placing enroll.mobileconfig file in MigratorResources directory (see [appendix for instructions](#retrieve-automated-enrollment-profile) on how to retrieve this profile)
	2. Configuring `com.vmware.migrator.plist` with desired options
	3. Editing any of the customization scripts
3. Open up Terminal and cd to the migrationToolWS1 directory that was downloaded
4. Build the pkg using the following command - edit the pkg name to help keep track of version history as needed:
`pkgbuild --install-location / --identifier "com.vmware.migrator" --version "1.0" --root ./payload/ --scripts ./scripts/ ./build/migrator_v1.pkg`
5. The pkg will then be able to be retrieved from the `build` directory

## Notes
- Logging:
	- The tool will log to `/var/log/vmw_migrator.log`
- Workspace ONE Intelligent Hub
	- At the end of the migration the tool will download and install the Hub for the user
	- There is an option to supply the Hub pkg in the migrator pkg to avoid the download if needed
		- Place the hub pkg at the following location: `/Library/Application Support/VMware/MigratorResources/hub.pkg`
- Admin privileges
	- In order to install and approve the MDM profile to enroll to Workspace ONE, the user on the Mac must have admin privileges
	- As part of the migrator tool, it will promote any standard user to admin to complete this and then revert back to standard when done
	
## Appendix
### Retrieve Automated Enrollment Profile
1. Navigate to Groups & Settings / All Settings / Devices & Users / Apple / Automated Enrollment
2. Ensure you are at the Organization Group where you are wanting the Mac devices to enroll to
3. Once the "Current Setting" is set to "Override" make the following selections:
	1. Enable Automated Enrollment: Enabled
	2. Platform: macOS
	3. Staging Mode: Single User Device
	4. Default Staging User: Default Staging User (or your desired staging account)
4. Select "Save"
5. Once the page refreshes, select "Export" and this will download the `mobileconfig` profile
6. Rename this file to `enroll.mobilconfig` and place in the `MigratorResources` directory

## Required Changes/Updates

- Updates to come:
  - DEP enrollment functionality

## Change Log

- 2022-08-08: Created Initial File
