# Workspace ONE Intelligence SDK sample app for Android

## Overview
- **Author**: Andreano Lanusse
- **Email**: alanusse@vmware.com
- **Date Created**: 05/01/2019
- **Supported Platforms**: Workspace ONE Intelligence SDK 5.8.11+


## Purpose

This sample includes the complete source code of an iOS sample app that integrates with Workspace ONE Intelligence SDK.

The app allows the user to generate App Loads, User Flows, Network Insight, Crash and Exception Handled events, which will be sent to Workspace ONE Intelligence and Apteligent Console based on the AppID configured to deploy the app.

The final binary of this application is not included, which requires to compile this project using XCode to generate the IPA file and deploy on your device for testing.

## Requirements

In order to compile this app the followin requirements are needed:

1. Android Studio 3.3+
2. Workspace ONE Intelligence SDK jar file



## How to compile the App and execute

In order to execute this app on your device or an emulator you need to:

1. Download the source code on your local machine
2. Download the Workspace ONE Intelligence SDK (formely known as Apteligent SDK) from [here](https://docs.apteligent.com/android/android.html#guides), and reference to the project source code
3. Register this App on your Workspace ONE Intelligence Console to obtain the App ID, and the App Key on Apteligent Console
5. For debug porpose you can hard code the App ID on your app, look for "HARD CODE YOUR APP ID HERE" into the MainActitity.java - when deploying this app as managed app through Workspace ONE UEM you can set the APP ID as Application Configuration parameters in the UEM Console and remove the hard code APP ID


## Change Log

## Additional Resources
[Workspace ONE Intelligence User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-AWT-WS1INT-OVERVIEW.html)
[Apteligent Android Guide](https://docs.apteligent.com/android/android.html)
