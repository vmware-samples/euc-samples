# macOS Baselines

## Overview

- **Authors**: Matt Zaske
- **Email**: mzaske@vmware.com
- **Date Created**: 6/16/2022
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

## Deploying via Workspace ONE with Freestyle Orchestrator

The fun begins! By now we should have all the files needed to deploy our baseline configuration out to our macOS devices. 

#### Profiles
#### Scripts
#### Sensors
#### Workflow

## Deploying via Workspace ONE without Freestyle Orchestrator
