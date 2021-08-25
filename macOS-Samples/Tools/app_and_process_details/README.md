# Get App and Process Details

This is a helper for the Workspace ONE Intelligent Hub for macOS feature for blocking apps and processes. 

[VMware Docs for Apps and Process Restrictions for macOS](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/macOS_Platform/GUID-1457AF26-9546-49E5-8D63-6D9162604456.html?hWord=N4IghgNiBcIEoFMDOAXATgSwMYoAQFswsB5AZVwEEAHKibMFDAewDslcAyXABTSa2RJkIAL5A) 

## Author
Created by Adam Matthews (matthewsa@vmware.com;adam@adammatthews.co.uk) GitHub: [adammatthews](https://github.com/adammatthews) Twitter: [@AdamPMatthews](https://twitter.com/AdamPMatthews)


## Installation

A Mac is required to run this tool. Download the appblocker.py script. Ensure you have Python 3 installed, no additional packages required. 

## Usage

On a Mac where you have the apps you intend to block installed, follow the below steps. 

```shell
python3 appblock.py --list
```
```shell
python3 appblock.py --app /System/Applications/Utilities/Terminal.app
```
--List will show you an output of all installed applications on your Mac, under /Applications, /System/Applications and /System/Applications/Utilities. 

--apps "application path" will show the details required to populate the Custom XML payload to set up the App and Process blocking feature. 

## Output 

If you are setting up a new profile, use the entire output, and remove the comment lines. 

If you are adding an additional app to an existing profile, jusy copy the lines between the comments to the initial array. 

```shell
% python3 appblock.py --app /System/Applications/Utilities/Terminal.app
<dict>
	<key>Restrictions</key>
	<array>
======= Beginning of app config (delete this line) ========
<dict>
	<key>Attributes</key>
	<dict>
		<key>cdhash</key>
			<string>de7001f2c2558fd399dbbde024dd767814ea03d0</string>
		<key>name</key>
		<array>
			<string>Terminal</string>
		</array>
		<key>path</key>
			<string>/System/Applications/Utilities/Terminal.app/Contents/MacOS</string>
		<key>bundleId</key>
		<array>
			<string>com.apple.Terminal</string>
		</array>
	</dict>
	<key>Actions</key>
	<array>
		<integer>1</integer>
	</array>
	<key>Message</key>
	<string>You are not permitted to use the Terminal App</string>
</dict>
======= Bottom of Payload (use if required, delete this line) ========
	</array>
	<key>PayloadDisplayName</key>
	<string>Restricted Software Policy</string>
	<key>PayloadIdentifier</key>
	<string>HubSettings.93f1655a-59fb-42dc-bc31-9571275cb12b</string>
	<key>PayloadOrganization</key>
	<string>VMware</string>
	<key>PayloadType</key>
	<string>com.vmware.hub.mac.restrictions</string>
	<key>PayloadUUID</key>
	<string>2b3eb9a9-fd31-4b94-8460-c9702e42dccc</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
</dict>
```

## Contributing
Changes and improvements welcome. Please follow the VMware Contribution guide for this repository. 

## License
[BSD 3-Clause License](https://github.com/vmware-samples/euc-samples/blob/master/LICENSE)