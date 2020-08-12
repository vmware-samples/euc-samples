# Safepassage to Workspace ONE UEM for macOS

This tool is designed to be flexible to fit many different use cases and enrollment requirements. There is no default mode, so you must understand how the tool works in order to configure it for your needs.

This tool is designed to work with DEPNotify for an easy-to-configure UI. Understanding the many capabilities of DEPNotify and how to configure it is highly recommended to create a great migration experience.

-------------------------------------------------------------------

To use this tool, you must first make some decisions on how the migration and enrollment experience should be. 


## What do you want the experience to be?
1. **I want it completely silent and transparent to the end user.**
	* Unfortunately this is not really a viable option anymore. Since macOS 10.13.4, some critical functionality in MDM requires User Approved MDM Enrollment such as installing Kernel Extension whitelists or Privacy Preference policies.
	* It technically can still be done, but it is not recommended and is not built-in with this tool. Also, the capability is expected to be removed in macOS 10.16.

2. **I want minimal user interaction and visuals, just enough for User Approved MDM Enrollment.**
	* Typically this means you will not require users to do any form of enrollment authentication to complete the migration.

	
3. **I want to require users to enter some information or authenticate to complete the migration.**
	* This is where things start getting more complex and may require you to make special customizations to the tool.

4. **I dont need my users to do anything special, but I want them to have a great visual experience throughout the migration to explain the process and tell them when it's finished.**
	* This is the most typical migration we see, the evolution of #2, which balances complexity with a good UX, while also ensuring the enrollment is User Approved.

	
-------------------------------------------------------------------

## How does this tool work?
This tool is a collection of files and scripts distributed to targeted devices as a .pkg file. The assumption is that you use the prior MDM to install this .pkg or alternatively it is manually installed by a user.

As soon as the .pkg is installed, the following will happen:
1. Migrator (this tool) will install and load its Launch Daemon
2. The LaunchDaemon will execute the migration script with along with your configured parameters.
3. The migrator script will run in a defined order, behaving as you configure it, removing the prior MDM and then guiding the installation of Workspace ONE.
4. Migrator will gracefully exit and kill its process.


This tool installs a launchdaemon that executes a python script to perform the migration. The script comes with a number of flags and keys to define the behavior depending on use case. 

Example of how the script is executed via the launchdaemon plist:
```xml
<key>ProgramArguments</key>
<array>
	<string>/usr/bin/python</string>
	<string>/Library/Application Support/VMware/migrator.py</string>
	<string>--custom</string>
	<string>--removal-script</string>
	<string>/Library/Application Support/VMware/MigratorResources/removemdm.sh</string>
	<string>--sideload-mode</string>
	<string>--enrollment-profile-path</string>
	<string>/Library/Application Support/VMware/MigratorResources/enroll.mobileconfig</string>
	<string>--predepnotify-script</string>
	<string>/Library/Application Support/VMware/MigratorResources/predepnotify.sh</string>
	<string>--premigration-script</string>
	<string>/Library/Application Support/VMware/MigratorResources/premigration.sh</string>
	<string>--postmigration-script</string>
	<string>/Library/Application Support/VMware/MigratorResources/postmigration.sh</string>
	<string>--forced-restart-delay</string>
	<string>600</string>
</array>
```

**Note:** When editing the launchdaemon file, make sure the file permissions are set appropriately before building the package or you may run into issues.  You can use **chmod 644** after editing the file to ensure the file permissions are set correctly.

After updating the launchdaemon file as well as the various included scripts, use the following command in the project directory to build the package:

```
./buildpkg .
```


### Remove the origin MDM:

If you are doing a **Workspace ONE to Workspace ONE** migration, you must use the **--wsone** flag and also the following keys:

| Key | Type | Notes |
|---|---|---|
|  --wsone  | flag | Flag to specify a Workspace ONE migration. This flag requires the below keys to make the API calls to WSONE for Enterprise Wipe. |
|  --origin-apiurl  | string | Base url of the api server (e.g. "https://apiserver.awmdm.com") |
|  --origin-auth  | string |  Base64 encoded username and password (e.g. "Basic dXNlcm5hbWU6cGFzc3dvcmQ=" |
|  --origin-token  | string |  API token from UEM (e.g. "IgEM6tsn16D+6B41BlQvIW4k1xFQ2HDygxFYLXt0X9E=") |


If you are doing any **other vendor migration to Workspace ONE**, you must use the **--custom** flag and also the following key:

| Key | Type | Notes |
|---|---|---|
| --custom | flag | Flag to specify that it's a custom migration (not --wsone). This flag requires a removal script to be specified.
|  --removal-script  | string | Full absolute path of the script containing the steps to remove the prior mdm. you can put these scripts wherever you want, but it's recommended to use the same directory as in the example format (e.g. "/Library/Application Support/VMware/MigratorResources/removemdm.sh")|
		
		
		
### Choose how the device will obtain and install the new enrollment profile
Currently with this tool, there are two primary methods for obtaining and installing the new profile:

**Option 1 -** Sideload an exported staging enrollment profile from UEM Console (Settings > Devices & Users > Apple > Automated Enrollment), distributed with the migration tool. Devices should be pre-registered in UEM to the enrollment user. This is the recommended method for experience #2 and #4.
	
		--sideload-mode
		--enrollment-profile-path

use the **--sideload-mode** flag and also the **--enrollment-profile-path** key:

| Key | Type | Notes |
|---|---|---|
|  --sideload-mode  | flag | Flag to specify a migration workflow in which the enrollment mobileconfig is being sideloaded as part of the migration package. Requires the below key to specify the path where the mobileconfig file is dropped. |
|  --enrollment-profile-path  | string | Full absolute path of the mobileconfig file. you can put this wherever you want, but it's recommended to use the same directory as in the example format (e.g. "/Library/Application Support/VMware/MigratorResources/enroll.mobileconfig")|		
	
	
**Option 2 -** Use API's to fetch the enrollment profile and prompt the user for information. 

Important: This requires one-factor token enrollment to be enabled at Settings > Devices & Users > General > Enrollment.

		--dest-baseurl
		--dest-auth
		--dest-token
		--dest-groupid
		--dest-apiurl
		
| Key | Type | Notes |
|---|---|---|
|  --dest-baseurl  | string | Base url of the enrollment server (e.g. "https://ds1234.awmdm.com") |
|  --dest-auth  | string |  Base64 encoded username and password (e.g. "Basic dXNlcm5hbWU6cGFzc3dvcmQ=" |
|  --dest-token  | string |  API token from UEM (e.g. "IgEM6tsn16D+6B41BlQvIW4k1xFQ2HDygxFYLXt0X9E=") |
|  --dest-groupid  | string | Group ID for the OG the device will enroll to (e.g. "1234").  Note that this is the numerical "Location Group ID" used in the Workspace ONE UEM API.  |
|  --dest-apiurl  | string | Base url of the api server (e.g. "https://apiserver.awmdm.com") |
	
Optionally require the user to input identifying information with one of the below flags. However, if neither key is supplied, the script will try to use the local username.

		--prompt-username
		--prompt-email
		
These flags will cause DEPNotify to drop a prompt to the user requesting them to enter whichever identifier you specify via flag
		
		
### Customize the experience

This tool provides several different places to customize the migration experience, depending at what stage the user/device is at. You can write small scripts to run at specific stages and include them in the migration package.

All of these scripts are optional and not required for the migration.

	--predepnotify-script
	--premigration-script
		--donotwait-for-premig
	--midmigration-script
	--postmigration-script

	--prompt-for-restart
		--forced-restart-delay
		

| Key | Type | Notes |
|---|---|---|
| --predepnotify-script | string | Full absolute path of a script to run before DEPNotify is opened. This is where you should add all DEPNotify customizations like branding and content. (e.g. "/Library/Application Support/VMware/MigratorResources/premig.sh") |
| --premigration-script | string | Full absolute path of a script to run after DEPNotify has opened, but right before the Origin MDM removal step is performed. This is where you should add DEPNotify customizations that should occur before the migration begins. (e.g. "/Library/Application Support/VMware/MigratorResources/premig.sh") |
| --donotwait-for-premig | flag | Typically the tool waits for each script to run before going to the next step. In rare cases, you may have a script that could take a long time to process and the mdm removal step isn't dependent on its completion. |
| --midmigration-script | string | Full absolute path of a script to run after the origin MDM has been removed but before starting the process of obtaining & installing the destination mdm profile. This is where you should add DEPNotify customizations (like progress indicators to the user). (e.g. "/Library/Application Support/VMware/MigratorResources/midmig.sh")  |
| --postmigration-script | string | Full absolute path of a script to run after destination MDM profile has been installed. This is where you should add final DEPNotify customizations and inform the user of the migration completion. (e.g. "/Library/Application Support/VMware/MigratorResources/postmig.sh")  |
| --prompt-for-restart | flag | This flag triggers DEPNotify to prompt the user to restart the machine with a simple dialog. |
| --forced-restart-delay | string | Number of seconds to delay auto reboot after migration is complete. You can both prompt the user and include this too as a fallback if the user doesn't accept the prompt. (e.g. "900")|




## Example Configurations

**Example 1**
Conditions:
1. 3rd Party Vendor to Workspace ONE
	* --custom
2. Pre-registered devices using exported mobileconfig from UEM
	* --sideload-mode & --enrollment-profile-path
3. Scripts used to guide user through process via DEPNotify customizations 
	* --predepnotify-script & --premigration-script & --postmigration-script
4. Forced restart 600 seconds after migration completes
	* --forced-restart

```xml
<key>ProgramArguments</key>
<array>
	<string>/usr/bin/python</string>
	<string>/Library/Application Support/VMware/migrator.py</string>
	<string>--custom</string>
	<string>--removal-script</string>
	<string>/Library/Application Support/VMware/MigratorResources/removemdm.sh</string>
	<string>--sideload-mode</string>
	<string>--enrollment-profile-path</string>
	<string>/Library/Application Support/VMware/MigratorResources/enroll.mobileconfig</string>
	<string>--predepnotify-script</string>
	<string>/Library/Application Support/VMware/MigratorResources/predepnotify.sh</string>
	<string>--premigration-script</string>
	<string>/Library/Application Support/VMware/MigratorResources/premigration.sh</string>
	<string>--postmigration-script</string>
	<string>/Library/Application Support/VMware/MigratorResources/postmigration.sh</string>
	<string>--forced-restart-delay</string>
	<string>600</string>
</array>
```

**Example 2**
Conditions:
1. 3rd Party Vendor to Workspace ONE
	* --custom & --removal
2. Prompt user for info (username) and fetch enrollment profile
	* --dest-baseurl, --dest-auth, --dest-token, --dest-groupid, --dest-apiurl
3. No DEPNotify customizations, default behavior
4. No restart

```xml
<key>ProgramArguments</key>
<array>
	<string>/usr/bin/python</string>
	<string>/Library/Application Support/VMware/migrator.py</string>
	<string>--custom</string>
	<string>--removal-script</string>
	<string>/Library/Application Support/VMware/MigratorResources/removemdm.sh</string>
	<string>--prompt-username</string>
	<string>--dest-baseurl</string>
	<string>https://https://testdriveds.awmdm.com</string>
	<string>--dest-auth</string>
	<string>Basic dXNlcm5hbWU6cGFzc3dvcmQ=</string>
	<string>--dest-token</string>
	<string>IgEM6tsn16D+6B41BlQvIW4k1xFQ2HDygxFYLXt0X9E=</string>
	<string>--dest-groupid</string>
	<string>1234</string>
	<string>--dest-apiurl</string>
	<string>https://as1373.awmdm.com</string>
</array>
```

**Example 3**
Conditions:
1. Workspace ONE to Workspace ONE
	* --wsone, --origin-apiurl, --origin-auth, --origin-token
2. Pre-registered devices using exported mobileconfig from UEM
	* --sideload-mode & --enrollment-profile-path
3. Scripts used to guide user through process via DEPNotify customizations 
	* --predepnotify-script & --midmigration-script & --postmigration-script
4. No restart


```xml
<key>ProgramArguments</key>
<array>
	<string>/usr/bin/python</string>
	<string>/Library/Application Support/VMware/migrator.py</string>
	<string>--wsone</string>
	<string>--origin-apiurl</string>
	<string>https://as1373.awmdm.com</string>
	<string>--origin-auth</string>
	<string>Basic dXNlcm5hbWU6cGFzc3dvcmQ=</string>
	<string>--origin-token</string>
	<string>IgEM6tsn16D+6B41BlQvIW4k1xFQ2HDygxFYLXt0X9E=</string>
	<string>--sideload-mode</string>
	<string>--enrollment-profile-path</string>
	<string>/Library/Application Support/VMware/MigratorResources/enroll.mobileconfig</string>
	<string>--predepnotify-script</string>
	<string>/Library/Application Support/VMware/MigratorResources/predepnotify.sh</string>
	<string>--midmigration-script</string>
	<string>/Library/Application Support/VMware/MigratorResources/midmigration.sh</string>
	<string>--postmigration-script</string>
	<string>/Library/Application Support/VMware/MigratorResources/postmigration.sh</string>
</array>
```





