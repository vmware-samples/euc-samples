# Workspace ONE mobileconfig Importer
* Author: Paul Evans
* Date Created: December 2020 (Note: no longer receiving updates)
* Most recently validated against:
  * macOS Sonoma 14
  * Workspace ONE UEM 2306


The Workspace ONE mobileconfig Importer gives you the ability to import existing mobileconfig files directly into a Workspace ONE UEM environment as a Custom Settings profile, import app preference plist files in order to created managed preference profiles, and to create new Custom Settings profiles from scratch. When importing existing configuration profiles, the tool will attempt to separate each PayloadContent dictionary into a separate payload for the Workspace ONE profile.

![Workspace ONE mobileconfig Importer](https://github.com/pevans00/euc-samples/assets/53051545/60d2bc3c-20e8-455e-8a6c-b115a711e1d8)



### To connect to your Workspace ONE UEM environment
1. From the menubar, select Workspace ONE mobileconfig Importer > Preferences.
2. Enter in the API information needed to connect to your Workspace ONE UEM environment:
    1. URL: Your Workspace ONE UEM API URL (typically https://asxx.awmdm.com)
    2. Key: Your API Key (created in the WS1 UEM Console under Settings > System > Advanced > API > REST API)
    3. Username: The username for a WS1 UEM administrator account d. Password: The password for a WS1 UEM administrator account
3. Select Test Connection to validate the connection is successful.
4. Select Save. Note that the URL, Key, and Username, and Password will all be saved to the Keychain.

### To load a mobileconfig file into the WS1 mobileconfig Importer:
1. Select the Select a File button.
2. Select a valid mobileconfig or plist file on your machine.
3. The tool will automatically attempt to parse the file and import the profile Name, Description, and PayloadContent array. As appropriate, the PayloadContent array will be split into separate payloads that will be enumerated and individually viewed using the Payload Content Dropdown.
4. Within the Payload Content window, view the individual payload to validate that the configuration is correct. Use the Test Payload button to print out the payload text to ensure the payload is accurate.

### To modify an existing payload, or create a new payload:
1. To make a new payload, use the '+' button to the right of the Payload Content Dropdown. This will append a new payload to the end of the array.
2. To remove the current payload, use the 'X' button to the right of the Payload Content Dropdown. This will shift any subsequent payloads forward in the array.
3. To add a new key to the payload, use the New Key button at the bottom of the Payload Content window.
4. When creating/editing a mobileconfig that contains a CFPreference domain, you can use the New MCX button as a shortcut to build the expected payload structure.
5. For any new keys, specify the name, type, and value in the Payload Content window. Note: A key type cannot be edited once selected. If needed, delete the key and create a new one to modify the type.
6. For keys of type "Dict" or "Array", you can use the '+' button to the right of the key to add children.
7. Use the 'X' button to the right of a key to remove it.
8. A key with an empty type will not be included in the payload. A key with an empty name will be, but it will have no name specified (use the Test Payload button to validate how different changes affect the payload).

### Notes about creating payloads:
1. By default, the tool will include certain required payload keys if they are not explicitly specified (such as PayloadIdentifier, PayloadUUID, etc). These will all be visible by using the Test Payload button. You can override these values by specifying the keys in the Payload Content window.
2. When creating a payload specifying a CFPreference domain, make sure the PayloadIdentifier field is prefixed by the domain (for example, com.apple.Siri.myIdentifier) to ensure functionality.

### To import the current profile into Workspace ONE:
1. When your API settings have been validated, the Managed OG list should load automatically depending on the Role of the admin user specified.
2. When a Managed OG has been selected, the corresponding Smart Groups list will load as well. Note that a profile can only be assigned to Smart Groups that are visible at the Managed OG level. If no Smart Groups are selected, the profile will be created in an unassigned state.
3. Select Create Profile to create a profile in Workspace ONE UEM based on the Profile Name, Description, and Payload Content specified for the profile.
