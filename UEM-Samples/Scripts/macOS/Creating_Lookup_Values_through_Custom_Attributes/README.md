# Creating Lookup Values through Custom Attributes for macOS Scripts

### Overview
* Author: Paul Evans
* Email: pevans@vmware.com
* Date Created: 7/29/2019
* Supported Platforms: WS1 UEM 1907
* Tested on macOS Versions: macOS Mojave

When deploying any type of macOS script (ie: preinstall, postinstall, or a standalone script) through Workspace ONE, there may be situations where you need to programmatically reference user- or device-specific informations within the script itself.  Custom Attributes can be created to define this information in a way that can be looked up on each device within the script itself.

### Defining a Custom Attribute

When you deploy a "Custom Attributes" profile payload to a macOS device, you will be able to store the returned value of a defined script as an attribute within Workspace ONE.  However, these attributes are also referenceable on the device side, stored in a plist file located at:

```/Library/Application Support/AirWatch/Data/CustomAttributes/CustomAttributes.plist```

From the device, you can use the ```defaults``` command to look up any particular attribute stored within that plist file.

Within the "Custom Attributes" payload you can use the standard lookup values supported by the Workspace ONE UEM Admin Console.  For example, you can use the {EmailAddress} lookup value to store the email address of the enrolled user of the device (as identified within the WS1 enrollment user account) in a custom attribute with the following command:

```bash
#!/bin/bash
echo "{EmailAddress}"
```

![CustomAttribute.png?raw=true](/macOS-Samples/Scripts/Creating_Lookup_Values_through_Custom_Attributes/bin/CustomAttribute.png)

### Using the Custom Attribute within a script

Once the Custom Attribute has been defined and deployed to the device, you will be able to reference it from within a script with the following command:

```bash
testAttribute="$(defaults read '/Library/Application Support/AirWatch/Data/CustomAttributes/CustomAttributes' 'Lookup Value')"
```

where 'Lookup Value' is the name of the Custom Attribute defined in the profile.  This will define the "testAttribute" variable to be used whenever needed in your script.  The following example shows how to access the "EmailAddress" custom attribute defined above:


```bash
#!/bin/bash

EmailAddress="$(defaults read '/Library/Application Support/AirWatch/Data/CustomAttributes/CustomAttributes' 'EmailAddress')"

echo "My email address is $EmailAddress"
```

![postinstall_script.png?raw=true](/macOS-Samples/Scripts/Creating_Lookup_Values_through_Custom_Attributes/bin/postinstall_script.png)
