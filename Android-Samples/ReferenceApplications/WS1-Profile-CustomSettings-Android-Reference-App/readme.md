# Workspace ONE UEM - Android - Custom Settings MDM Profile - Reference Application 

## SYNOPSIS
This application is useful for demonstrating how to retrieve values from a Workspace ONE UEM MDM profile. These values can be used
throughout an Android application, and eliminate the need to build separate applications with different hardcoded values. 
This allows the use of key value pairs (KVP) in a custom settings profile payload to be read by the restrictions manager Android class.


## DESCRIPTION
This sample application and Workspace ONE UEM MDM profile provides a working example of how to implement restrictions manager.
KVP's can be defined in the MDM profile, and delivered to the application. Benefits to passing these values from a Workspace ONE UEM
MDM profile include removing hardcoded values in applications. This allows reusing applications for multiple environments, use cases,
scenarios, and needs.

In my experience, typical values passed include;  a URL, OAuth client ID, ADFS resource, OAuth authorization endpoint, 
application environment, feature flags, device serial number, enrolled user (or checked out user, in shared device use case), etc.


For additional information about Android Enterprise and Restrictions Manager,
see the following URL's below;

https://developer.android.com/work/managed-configurations

http://android-doc.github.io/training/enterprise/app-restrictions.html

https://developer.android.com/reference/android/content/RestrictionsManager.html

---

## GETTING STARTED

1. Refer to WS1-Profile.xml for the reference Workspace ONE UEM MDM Profile 'Custom Settings' payload for Android. This profile 
   has key/value pairs which are passed to the Android native application. This allows for the values to be read in 
   the application code. Customize these values as you see fit. Take note of the dynamic lookup values which are 
   retrieved by Workspace ONE Intelligent Hub agent.
2. Create a profile in Workspace ONE UEM that has the appropriate key value pairs for your application.
3. Customize your application code to use AppConfig.java, as per your environments needs. 


---

## OUTPUTS

I/System.out: Here is the Environment: PROD

I/System.out: Here is the URL: https://www.vmware.com

I/System.out: Here is the Example Value: ExampleValue

I/System.out: Here is the Serial Number: {FA7280304391}

I/System.out: Here is the User: {Maui}

I/EUCPSO: Here is the Environment: PROD

I/EUCPSO: Here is the URL: https://www.vmware.com

I/EUCPSO: Here is the Example Value: ExampleValue

I/EUCPSO: Here is the Serial Number: {FA7280304391}

I/EUCPSO: Here is the User: {Maui}

---

## NOTES

* Version:        4.1
* Creation Date:  02/25/2022
* Author:         Ryan Pringnitz - rpringnitz@vmware.com
* Author:         Made with love in Kalamazoo, Michigan
* Purpose/Change: Initial Release