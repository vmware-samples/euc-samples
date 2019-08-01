# **Workspace ONE ApplicationManagement-Samples**

## **Overview**
* **Author(s)** : Manisha R, Nurul Quamar Khan
* **Email** : manishar@vmware.com, khann@vmware.com
* **Date Created** : 16 June 2019

## **Purpose**
The tool provides an example of how the Application APIs can be used. This script automates Application workflow i.e. an application can be deployed to WS1 UEM server and pushed down to a device by executing this script. Assignments to an application can also be edited using this script.

## **Requirements**
To execute the script, dependencies have to be installed.
This tool uses Python's PIP installation system.
Dependencies can be installed by executing the following command:
` pip install -r requirements.txt `

## **How to execute the script**
config.py file has to be updated with appropriate values before executing the script. This file has settings like the environment URL, WS1 tenant, smart group, etc.

### **Command to execute the script**
` python deployment.py <options> <File Path> <Application Name> <Build Information> <Deployment Types> <Push Mode> <Retire Previous Version> <Supported Models> <Device Type> `

Application Deployment workflow needs the following required parameters:
1. File Path - Absolute file path of the application.
2. Application Name - Name of the application.
3. Build Information - Comma separated Build Project Name and Build Number. (Ex: "My App Build Project,1")
4. Deployment Types - Supported values are Alpha, Beta, and Prod. These are the assignment groups. Multiple values can be given as a comma-separated value. (Ex: "Alpha,Beta")

Build Information is used to track which Apps and builds are being uploaded and promoted.

Optional parameters:
options - Three options are available.
1. -h/ -- Help: Gives the details on how to use the script.

2. -v {Value}/ --Version {Value} : Use this option to provide a custom numeric version(Up to 3 digits), if the actual file version is a alpha numeric version or it is a 4 or more digits version (Ex: python deployment.py -v "1.0.0" "app.apk" "App Build Project,1" "Alpha,Beta")

3. -a {Value}/ --AppID {Value} : Use this in case you want to edit the assignment of an existing app. AppID can be found out from the appdetails.json that was generated when the app was deployed using this script (Ex: python deployment.py -a 1234 "app.apk" "App Build Project,1" "Alpha,Beta,Prod")

**Note** - Assignments for applications deployed using this script can only be edited

4. Retire Previous Version - This is a flag that can hold True/False. This is set to False by default. If this set to True, previous version of the app that is going to be deployed will be retired.

5. Supported Models - This is a list of device models that the app supports. (This is a required parameter in case of Windows Universal App - appx). Supported values are Android, iPhone, iPod Touch, iPad, Windows Phone 8, Windows Phone 10, Desktop, HoloLens

6. Device Type - Supported Device Type(This is a required parameter in case of Windows Universal App - appx). Supported values are Android, Apple, windowsphone8, winRT

Currently, the first time when an app is published with Alpha deployment mode an appdetails.json file is created in the working directory and has the app, productid, build information, version and deployment type details.
This is being used in the script to decide what state the app deployment is for a particular build.

Example: {"45": {"app_id": 483, "product_id": 0, "app_version": "5.73.0", "current_deployment": "Prod"}}

## **Integrating with Jenkins**
jenkins_build_information.py is a python script that has been written to fetch jenkins build information.

This script can be integrated with jenkins as follows:
1. Download and install jenkinsapi library by executing the command 
`pip install jenkinsapi`
2. Fill in the Build server details in config.py
3. Configure the post build action in the build pipeline
4. Provide the absolute path of jenkins_build_information.py for Build Information argument.

## **Integrating the Script with a Build Server**
The script can be integrated with any build server as follows:
1. To integrate the script, fill in the Build server details in config.py
2. Write a Python script to call an appropriate Build Server API to get the build information.
3. Add a post build action in the build pipeline
4. Provide the absolute file path of the Build Server API client written in place of <Build Information> argument.


## **Testing**
End to End test cases have been added under the folder 'testing'. Please refer ReadMe file under testing folder for more details on how to run the test cases.

## **EndPoints Used**
1. CHUNK_UPLOAD_URL = '/api/mam/apps/internal/uploadchunk'
2. APP_UPLOAD_URL = '/api/mam/apps/internal/begininstall'
3. APPLICATION_SEARCH_URL = '/API/v1//mam/apps/search'
4. APPLICATION_ADD_ASSIGNMENT_URL = '/api/mam/apps/internal/{application_id}/assignments'
5. APPLICATION_EDIT_ASSIGNMENT_URL = '/api/mam/apps/internal/{application_id}/assignments'
6. RETIRE_APPLICATION_URL = '/api/mam/apps/internal/{application_id}/retire'
7. APPLICATION_DETAILS_URL = '/api/mam/apps/internal/{application_id}