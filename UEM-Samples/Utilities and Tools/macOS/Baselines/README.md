# macOS Baselines

## Overview

- **Authors**: Matt Zaske
- **Email**: mzaske@vmware.com
- **Date Created**: 6/23/2022
- **Supported Platforms**: Workspace ONE UEM v2204
- **Tested on macOS Versions**: macOS Monterey

## Purpose

Utilizing the macOS Security Compliance Project (mSCP) to enforce baselines on macOS devices using Workspace ONE. We will review briefly how to use the mSCP to generate the baseline you are wanting to configure and then go into detail on how to deploy this configuration using Workspace ONE. We will review two different deployment options as well for environments that are Freestyle enabled and those that are not. Here is a high level overview:

1. [Prerequisites for mSCP](#prerequisites-for-mSCP)
2. [Generating a Baseline](#generating-a-baseline)
3. [Generating Guidance](#generating-guidance)
4. [Deploying via Workspace ONE with Freestyle Orchestrator](#deploying-via-workspace-one-with-freestyle-orchestrator)
    1. [Deploying via Workspace ONE without Freestyle Orchestrator](#deploying-via-workspace-one-without-freestyle-orchestrator)
6. Reporting via Workspace ONE Intelligence

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

At this point you have all the files needed to begin deploying the baseline using Workspace ONE
- If your environment is enabled with Control Plane architecture and Freestyle Orchestrator, follow the [Deploying via Workspace ONE with Freestyle Orchestrator instructions](#deploying-via-workspace-one-with-freestyle-orchestrator)
- If it is not, follow the [Deploying via Workspace ONE without Freestyle Orchestrator instructions](#deploying-via-workspace-one-without-freestyle-orchestrator)
- In order to determine if your environment has Freestyle Orchestrator look for the icon in the upper left of your UEM Console:
<p align="center">
    <img src="https://user-images.githubusercontent.com/63124926/174119436-70f0cf2d-f00e-4269-8e74-acb286141a09.png">
</p>

## CHANGE
- Deploy Profiles
- Deploy Script via Apps & Books
- Deploy Sensors to collect Data (formerly Custom Attributes)
- Remediation
    - Branch here to Freestyle and non-Freestyle

## Deploying via Workspace ONE with Freestyle Orchestrator

The fun begins! By now we should have all the files needed to deploy our baseline configuration out to our macOS devices. 

#### Profiles
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
-  Utilizing the same tool as deploying the Audit plist we will upload the mobileconfig files to WS1 UEM - [Workspace ONE Mobileconfig Importer fling](https://flings.vmware.com/workspace-one-mobileconfig-importer)
-  The process is the same as before: "Select File", navigate to the `../build/{baseline}/mobileconfigs/unsigned` and select a file, give it a Name/Description, select your managed OG and smart group, and then "Create Profile"
    - You will need to repeat this step for each mobileconfig file in the directory. For example there are 14 profiles for CIS Level 1 baseline. 
        - ![image](https://user-images.githubusercontent.com/63124926/174332315-d78fe2e8-bc54-4074-94e1-4cf476cc2818.png)
- After completing the importing of these files you are all set from a profile perspective. 

#### Scripts, Sensors, and Workflow

Moving on to the Scripts section. There is one main script that is versatile in what it can do (i.e. scan, remediate, pull stats, etc.) This script is located at `../build/{baseline}/{baseline}_compliance.sh`. In order to deploy this with WS1 we will follow the following methodology:
- Compliance scan run at predetermined interval (i.e. every 12 hours)
- After compliance scan complete, collect stats using Sensor
- Using Workflow within Freestyle Orchestrator - trigger Remediation if device is not 100% compliant

We will start with the Sensors. Utilizing the compliance script there are different flags that trigger different behaviors. For the Sensors we will focus on the reporting and collecting the compliance data. There are many different data points you might be interested in: Compliant Count, Non-compliant Count, % Compliant, etc. For this example I am going to walk through the creation of a Sensor for "Non-compliant Count" and you can utilize this to create whatever other Sensors you need:
1) Navigate to Resources>Sensors in your Workspace ONE UEM Console and select Add>macOS
2) Fill out the "General" tab by giving your Sensor a name. I will use cis_noncompliant_count
3) After selecting "Next" you will be taken to "Details." Leave the top 2 dropdowns as default values (bash and system)
4) Edit the "Response Data Type" to be an integer
5) Open up the compliance script located at `../build/{baseline}/{baseline}_compliance.sh`
6) Copy/paste the entire contents into the text editor in WS1 UEM
7) In order to capture the data you want, you will need to modify lines 4797-4814 (end)
    - You will delete all of these lines and repalce it with the action you are wanting
    - In my example, I want the non-compliant count so I will use `compliance_count "non-compliant"`
    - See screenshot below of how it should look after you are done:
    - ![image](https://user-images.githubusercontent.com/63124926/175406992-d7476eb1-8858-4dac-a1fb-daec8d7a5696.png)
8) You will then select "Next" followed by "Save & Assign"
9) Complete the assignment and select the Deployment Trigger as "Periodically"


## Deploying via Workspace ONE without Freestyle Orchestrator

Coming Soon

## Notes
- On a given device you can view the full Audit Log at `/Library/Logs/{baseline}_baseline.log`

## Resources
important links or sources?

## Required Changes/Updates

- Add deployment details using Workspace ONE UEM without Freestyle Orchestrator
- Add functionality to upload full audit log to Workspace ONE UEM Console

## Change Log

- 2022-06-23: Created Initial File
