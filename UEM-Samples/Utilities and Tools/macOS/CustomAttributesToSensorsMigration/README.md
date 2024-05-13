# EUC-samples is now hosted https://github.com/euc-oss/euc-samples.
# This repo is no longer maintained.

# Custom Attributes to Sensors Migrator

### Overview
* Author: Paul Evans, Mike Nelson
* Email: pevans@vmware.com, miken@vmware.com
* Date Created: 11/11/2020
* Supported Platforms: WS1 UEM 20.11+

This script can be used to migrate existing Custom Attributes profiles that are configured in a Workspace ONE UEM environment to a Sensor configured in the same environment.  The script works in two parts:

1) First, you will download the metadata of your existing Custom Attributes profiles, including the assignments, which will be saved in the ./SensorData folder as individual .json files

2) Once the metadata has been downloaded and verified, you will use this data to create Sensor resources.  The original Custom Attributes profiles in the environment will not be affected.

### Setup

The folder contains a settings.conf file that must be updated with the following values:

* APIServer (example: as135.awmdm.com)
* Username
* Password
* APIKey
* KeepSensorAssignment (1 or 0.  If 1, all created Sensors will maintain the existing assignment.  If 0, created Sensors will remain unassigned).

### Usage

Launch the script by opening Terminal and navigating to the working directory.  Then use the following command to launch:


```
python sensormigrator.py

```

Once launched, you will see the following menu:

```
Select operation
1: Get Custom Attribute Profiles from Source Tenant
2: Upload Sensors to Destination Tenant
0: Exit
```

Enter "1" to perform the first step of the migration and save your existing Custom Attribute metadata to the ./SensorData/ folder within your working directory.  After step 1 completes successfully, you can navigate to this folder to validate that the information looks correct.

Once step 1 is complete you will return to the menu.  Select "2" to create Sensor Resources for each of the metadata files saved in the ./SensorData folder.  The script will parse the interpreter directive at the first line of each Custom Attribute (ie: #!/bin/bash) to determine if the language is Bash, Python, or Zsh.  If the settings.conf file has KeepSensorAssignment set to 1, the assignment of the Custom Attribute will be maintained in the created Sensor.

**Note:** Logging will be printed to the Terminal window as well as to the native Console log.  You can flag by searching for the [SensorMigrator] tag.