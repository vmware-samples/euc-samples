# macOS Baselines

## Overview

- **Authors**: Matt Zaske
- **Email**: mzaske@vmware.com
- **Date Created**: 6/29/2022
- **Supported Platforms**: Workspace ONE UEM v2204
- **Tested on macOS Versions**: macOS Big Sur

## Purpose

Utilizing the macOS Security Compliance Project (mSCP) to enforce baselines on macOS devices using Workspace ONE. We will review briefly how to use the mSCP to generate the baseline you are wanting to configure and then go into detail on how to deploy this configuration using Workspace ONE. We will review two different deployment options as well for environments that are Freestyle enabled and those that are not. Here is a high level overview:

1. [Prerequisites for mSCP](#prerequisites-for-mSCP)
2. [Generating a Baseline](#generating-a-baseline)
3. [Generating Guidance](#generating-guidance)
4. [Deploying Baseline with Workspace ONE](#deploying-baseline-with-workspace-one)
    1. [Profiles](#profiles)
    2. [Script](#script)
    3. [Sensors](#sensors)
    4. [Remediation](#remediation)
        1. [Using Freestyle Orchestrator](#remediation-with-freestyle-orchestrator)
        2. [Using other methods](#remediation-without-freestyle-orchestrator)
5. [Reporting](#reporting)

## Prerequisites for mSCP

The first few sections are primarily going to follow along with the [mSCP wiki](https://github.com/usnistgov/macos_security/wiki) and how I go about utilizing the project to generate a baseline for CIS Level 1 in my example. First, we need to clone or download the project and necessary modules:
1) Using Terminal on your Mac, run the following commands:
```
git clone https://github.com/usnistgov/macos_security.git

cd macos_security

pip3 install -r requirements.txt --user

bundle install
```

2) This will drop all the project files locally on your Mac in a new directory called `macos_security`

## Generating a Baseline

Now that we have the files we need locally, we can work on [generating a proper baseline file](https://github.com/usnistgov/macos_security/wiki/Generate-a-Baseline). There are many built-in baselines to choose from and they can be seen by using the following command:
```
./scripts/generate_baseline.py -l
```
In my example here I will be using the predefined 'cis_lvl1' baseline. If you are planning to use a predefine baseline there is nothing further for you to do in this step as the YAML file should already be created and located in the `../macos_security/baselines` directory. 
  - You are able to customize the baselines and generate your own tailored baseline using the following command.
  ```
  ./scripts/generate_baseline.py -k name_of_baseline
  ```
  - More details on customization can be seen [here](https://github.com/usnistgov/macos_security/wiki/Customization)

## Generating Guidance

By this step you should have your baseline's YAML file identified from the previous section. Using that YAML file you will generate guidance which is all of the profiles and scripts needed to deploy using WS1. In addition you will generate some text documents (adoc, HTML and PDF) that are useful for audit purposes. In order to go ahead and generate this material you will use the following command:
```
./scripts/generate_guidance.py -p -s baselines/cis_lvl1.yaml
```
- In this command the -p flag triggers the creation of configuration profiles
- The -s flag triggers the creation of compliance script

This command will create all files and place them in the /build folder under the directory name of the baseline you are using (i.e. cis_lvl1)
- Within the `../build/preferences` directory you will see a plist file called `org.{baseline}.audit.plist`
  - Using this file you can set certain rules within a baseline to be [disabled or exempt](https://github.com/usnistgov/macos_security/wiki/Compliance-Script)

At this point you have all the files needed to begin deploying the baseline using Workspace ONE!

## Deploying Baseline with Workspace ONE

The fun begins! By now we should have all the files needed to deploy our baseline configuration out to our macOS devices. We are going to follow the following high level order of events:
1. Deploy Profiles
2. Deploy Script via Apps & Books
3. Deploy Sensors to scan & collect Data (formerly Custom Attributes)
4. Remediation (using Freestyle Orchestrator and without)

### Profiles
First up we will start with deploying the necessary configuration profiles. The mSCP tool will drop these into 2 locations outlined here:
- The organization audit plist is located at `../build/{baseline}/preferences` and is used by the tool to determine if any rules in the baseline should be exempt. This will be deployed via WS1 so it ends up in the `/Library/ManagedPreferences/` directory on the device.
    - To do this we will utilize the [Workspace ONE Mobileconfig Importer fling](https://flings.vmware.com/workspace-one-mobileconfig-importer)
    - Once you have installed the tool on your Mac, fill in your environment details under the Preferences menu option in the Menubar
    - After that, use the "Select File" option and navigate the the audit plist file in the `../build/{baseline}/preferences` directory
    - Give the profile a name and description in the upper left. Also select the managing OG of your UEM environment and the smart group you wish to assign the profile to. I have a screenshot of my example below:
        - ![image](https://user-images.githubusercontent.com/63124926/174325113-c7ce8358-b0db-406d-91a7-28990b287c9a.png)
    - Click "Create Profile" to go ahead and send the profile to your WS1 tenant using the API connection
    - Once it is there in UEM, there are 2 minor edits we need to make. Edit the profile and go down to the "Custom Settings" payload where you will find your profile XML. Select "Add Version" to begin editing:
        - Remove the first `<dict>` tag (delete line 1)
        - Toward the bottom of the XML we are going to remove the `</dict>` tag on the line right before `<key>PayloadIdentifier</key>` (seen in screenshot below)
        - Next we are going to rename the string for `<key>PayloadType</key>` from `<string>com.apple.ManagedClient.preferences</string>` to `<string>org.cis_lvl1.audit</string>` (seen in screenshot below)
            - ![image](https://user-images.githubusercontent.com/63124926/174324378-f6932a34-2f13-4795-bdcc-10f420237d7b.png)
    - Select "Save and Publish" to deploy the changes

- Next we need to deploy the configuration profiles needed to enforce certain rules within the baseline. These are located at `../build/{baseline}/mobileconfigs`. In this directory you will find a folder `unsigned` containing the unsigned mobileconfig files and a folder called `preferences` containing the raw plist files. For our purposes we will utilize the `unsigned` folder.
- Before using the tool to import the mobileconfig files to Workspace ONE, we will need to run the following command to delete an uneeded key from the files. Confirm you are still in the `macos_security` working directory and run the following command:
    - `for file in /Users/mzaske/Documents/github/macos_security/build/cis_lvl1/mobileconfigs/unsigned/*; do sed -i '' '5,9d' $file; done`
    - Replace `cis_lvl1` with the baseline you are deploying and point to the full path of the mobileconfig unsigned profiles
-  Utilizing the same tool as deploying the Audit plist we will upload the mobileconfig files to WS1 UEM - [Workspace ONE Mobileconfig Importer fling](https://flings.vmware.com/workspace-one-mobileconfig-importer)
-  The process is the same as before: "Select File", navigate to the `../build/{baseline}/mobileconfigs/unsigned` and select a file, give it a Name/Description, select your managed OG and smart group, and then "Create Profile"
    - ***You will need to repeat this step for each mobileconfig file in the directory. For example there are 14 profiles for CIS Level 1 baseline.*** 
        - ![image](https://user-images.githubusercontent.com/63124926/176467217-e84eaaca-984d-4015-a983-80ede9db314e.png)
- After completing the importing of these files you are all set from a profile perspective. 

### Script

Moving on to the Script section, there is one main script that is versatile in what it can do (i.e. scan, remediate, pull stats, etc.). This script is located at `../build/{baseline}/{baseline}_compliance.sh`. In order to deploy this with WS1 we will use a pkg we create:
1. There are many packaging tools out there you can use to accomplish this task, but for my example I will use pkgbuild CLI.
2. Essentially we want to deploy the script file, `{baseline}_compliance.sh`, to a known location on the device. For my example I will use the `private\var\cis` directory (cis referring to the baseline I am deploying in my example).
3. First I will build the file structure on my Mac to get ready to build the pkg. I will place the `{baseline}_compliance.sh` file in the `private\var\cis` directory:
    - ![image](https://user-images.githubusercontent.com/63124926/175644679-dfec6db9-c2cd-48a9-9294-b9ef29b30ad5.png)
4. After that we are ready to build the pkg. Navigate to the directory, `CIS Baseline` in my case, and execute the following command:
    - `pkgbuild --install-location / --identifier "com.vmware.cisbaseline" --version "1.0" --root ./payload/ --scripts ./scripts/ ./build/CISbaseline.pkg`
5. The pkg is dropped into the Build folder where you can grab it and go ahead and parse the pkg with VMware Admin Assistant
6. Edit the plist file that is created to ensure the 'Name' and 'Version' keys are in line with what you are expecting. 
    - The Name key is how the app will appear in the UEM console as well as on the user's Hub Catalog.
7. Upload the pkg and plist files to UEM using the Add Application workflow (Resources > Apps > Native > Internal)
8. Add the icon under Images tab (if desired)
9. Add the following scripts under the Scripts tab
    - Post Install Script - set permissions to root only so no users can modify:
    ```
    #!/bin/bash

    #path to file
    filepath=/private/var/cis/cis_lvl1_compliance.sh
    #permission to root only
    chmod 000 $filepath
    #make hidden
    chflags hidden /private/var/cis
    chflags hidden $filepath

    exit 0
    ```
    - Install Check Script - ensure script is in place and correct version (in case updates needed)
    ```
    #!/bin/bash

    #path to file and packageid
    filepath=/private/var/cis/cis_lvl1_compliance.sh
    pkgid=com.vmware.cisbaseline

    # version of baseline being deployed - coorelates to receipt version in munki plist
    target_version=1.0

    # Check if baseline script is installed first
    if [ -f $filepath ]; then

      #convert version number to individual
      function version { echo "$@" | /usr/bin/awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

      # Grab current CIS Baseline version installed via pkg receipt
      current_version=$(/usr/sbin/pkgutil --pkg-info $pkgid | /usr/bin/grep version | /usr/bin/awk '{print $2}')
      echo CIS Baseline current version: $current_version

      # Compare with version we are expecting
      if [ $(version $current_version) -lt $(version $target_version) ]; then
        # version installed is not current
        echo CIS Baseline not installed
        exit 0
      else
        # version installed is current or newer
        echo CIS Baseline is installed
        exit 1
      fi

    else
      # baseline is not installed - need to install
      echo CIS Baseline not installed
      exit 0
    fi
    ```
    - Uninstall Script - remove script file
    ```
    #!/bin/bash

    #path to file and packageid
    filepath=/private/var/cis/cis_lvl1_compliance.sh
    pkgid=com.vmware.cisbaseline

    rm -rf $filepath
    /usr/sbin/pkgutil --forget $pkgid

    exit 0
    ```
10. Select Save & Assign and go through your desired assignment criteria. The 3 requirements I would recommend are:
    - App Delivery Method: Auto
    - Display in App Catalog: Disabled
    - Restrictions > Desired State Management: Enabled
11. Save and Publish the app and assignment, you are done!

Now that the compliance script is present on the device, we can utilize it take action! We will do that using Sensors in the next section.

### Sensors

First things first, if you are on an older version of Workspace ONE UEM and do not see Sensors in your environment, you can accomplish everything we are doing here using [Custom Attributes profiles](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/ProdProv_All/GUID-BFEAAE97-D112-4B19-8DAB-E0C681F57DDF.html). Using Sensors we will be triggering the complaince scan to run on a periodic basis as well as collecting data from the device. The data I will be collecting is:
- Non-compliant rule count
- Last compliance scan date/time

There is certainly more data you could collect (compliant rule count, % compliant, etc.) if needed. We will start with the configuration of triggering the compliance scan and collecting the last compliance scan date/time:
1. Navigate to Resources>Sensors and select Add>macOS
2. Fill out the General tab with your desired name (Must be between 2 and 64 characters using only a combination of lowercase letters, numbers, and underscores. The first character must be a lowercase letter.)
    - I will use cis_compliancescan for my example
3. Select "Next" and you will move to the next section, "Details." Here we will change the language to `Zsh` and leave the next 2 options as the default values (System and String).
4. Provide the following script in the textbox to trigger the compliance scan using the --check flag and the collecting the last scan information:
```
#!/bin/zsh

#path to file and packageid
filepath=/private/var/cis/cis_lvl1_compliance.sh

#trigger compliance scan
zsh $filepath --check >/dev/null 2>/dev/null

#collect last scan date/time
lastComplianceScan=$(defaults read /Library/Preferences/org.cis_lvl1.audit.plist lastComplianceCheck)

if [[ $lastComplianceScan == "" ]];then
    lastComplianceScan="No scans have been run"
fi

echo "$lastComplianceScan"
```
5. Select "Next" followed by "Save & Assign" 
6. Select "New Assignment" and fill out desired assignment criteria. 
7. On the "Deployment" tab, select "Periodically" as the trigger. This will scan the device for compliance every 4 hours (default value).
8. Select "Save" followed by "Close" to complete the setup of this Sensor.  

Next, we will configure a Sensor to collect the non-compliant rule count. We will follow the same steps as before, but with the following modifications:
- Name: cis_noncompliant_count
- Language: Zsh
- Response Data Type: Integer
- Code: 
```
#!/bin/zsh

#path to file
filepath=/private/var/cis/cis_lvl1_compliance.sh

#trigger non-compliant count
zsh $filepath --non_compliant
```

### Remediation

Now that we have deployed all the scripts and profiles to our macOS devices, we need a way to ensure the device maintains complaince. To do this we need to execute the compliance script using the `--fix` parameter. In order to do this in WS1 we have a couple of options. We do not want to continually call the fix function if there is nothing to fix, so we will be utilizing our sensor from the last section `cis_noncompliant_count`. 

- If your environment is enabled with Control Plane architecture and Freestyle Orchestrator, follow the [Remediation with Freestyle Orchestrator instructions](#remediation-with-freestyle-orchestrator)
- If it is not, follow the [Remediation without Freestyle Orchestrator instructions](#remediation-without-freestyle-orchestrator)
- In order to determine if your environment has Freestyle Orchestrator look for the icon in the upper left of your UEM Console:
<p align="center">
    <img src="https://user-images.githubusercontent.com/63124926/174119436-70f0cf2d-f00e-4269-8e74-acb286141a09.png">
</p>

#### Remediation with Freestyle Orchestrator

In this section we will be building a Workflow that will trigger the remediation script to execute whenever the non-compliant count is greater than 0. To do this we will first add a Script:
1. Navigate to Resources>Scripts and then select Add>macOS
2. In the "General" tab, give your Script a name (CIS Remediation) and I recommend leaving App Catalog Custimization disabled so end users do not see this script in their catalog.
3. In the "Details" tab we will change the language to `Zsh` and leave the next 2 options as the default values (System and 30).
4. Provide the following script in the textbox to trigger the remediation scan using the --fix flag 
```
#!/bin/zsh

#path to file and packageid
filepath=/private/var/cis/cis_lvl1_compliance.sh

#trigger compliance scan
zsh $filepath --fix >/dev/null 2>/dev/null

#trigger non-compliant sensor to run and collect new value after remediation
/usr/local/bin/hubcli sensors --trigger cis_noncompliant_count

exit 0
```
5. Select "Next" followed by "Save"

Now we can move on to building our Workflow:
1. Select "Freestyle" in the top left of the UEM Console and you will be take to a new Freestyle Workflow (you might need to select "Get Started")
2. On this screen you will configure the following:
    - Name in top left
    - Platform: macOS
    - Assigned Smart Group
    - Condition: Sensor (cis_noncompliant_count) does not equal 0
        - **Under "Additional Settings" be sure to enable "Re-evaluate Condition"**
    - Resource: Script (CIS Remediation)
    - ![image](https://user-images.githubusercontent.com/63124926/176307317-96ffc088-cb87-43f5-aeca-5455bd6da9c1.png)
3. When complete, select "Publish" in the bottom right

Now you have fully deployed your Baseline to your macOS devices! Head to the [Reporting](#reporting) section for what you can do using Workspace ONE Intelligence.

#### Remediation without Freestyle Orchestrator

Without Freestyle Orchestrator we can make another Sensor (or Custom Attribute profile) perform a smilar function:
1. Following similar steps outlined [here](#sensors), we will add a new Sensor
    - Name: cis_remediation
    - Language: Zsh
    - Execution Context: System
    - Response Data Type: String
    - Code:
```
#!/bin/zsh

#path to file and packageid
filepath=/private/var/cis/cis_lvl1_compliance.sh

#check if script needs to run_fix
#if cis_noncompliant_count = 0 then exit
noncompliantCount=$(zsh $filepath --non_compliant)
if [[ $noncompliantCount == 0 ]]; then
  echo "Compliant"
  exit 0
fi

#trigger run_fix
zsh $filepath --fix >/dev/null 2>/dev/null

echo "Remediation in Progress"

exit 0
```
2. After saving the Sensor, you will create your assignment. 
3. Set your deployment trigger to "periodically" which will check to see if rememdiation is needed every 4 hours by default.

Now you have fully deployed your Baseline to your macOS devices! Head to the [Reporting](#reporting) section for what you can do using Workspace ONE Intelligence.

## Reporting

Coming Soon

## Notes
- On a given device you can view the full Audit Log at `/Library/Logs/{baseline}_baseline.log`

## Resources
These are linked throughout the walk-through, but here is a consolidated list:
- [macOS Security Compliance Project (mSCP) Overview](https://support.apple.com/guide/sccc/macos-security-compliance-project-sccc22685bb2/web)
- [mSCP wiki](https://github.com/usnistgov/macos_security/wiki)
- [Workspace ONE Mobileconfig Importer fling](https://flings.vmware.com/workspace-one-mobileconfig-importer)

## Required Changes/Updates

- Reporting via Workspace ONE Intelligence
- Add functionality to upload full audit log to Workspace ONE UEM Console

## Change Log

- 2022-06-29: Created Initial File
