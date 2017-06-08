# StartLayout CSP

## Overview
- **Author**: Josue Negron
- **Email**: jnegron@vmware.com
- **Date Created**: 6/8/2017
- **Supported Platforms**: Windows 10 Enterprise and Education
- **Tested on Windows 10**: 1607, 1703 (StartLayoutDevice.xml only supported in 1703)

## Purpose 
The StartLayout CSP is used to customized the Start Menu Layout of a device for a uniform look and feel for all of your corporate devices. Once customized users cannot modify the Start Menu.

There are two samples here: 


1. **StartLayoutUser.xml** - User based meaning only the managed (AirWatch) user on the device will receive the customized settings. 
2. **StartLayoutDevice.xml** - Device based (added in 1703) will apply to all users on the device. 

## Required Changes/Updates
You must update the data within the `<Data> </Data>` tags with your exported Start Layout from a pre-staged device. 

The **Export-StartLayout** cmdlet in PowerShell exports the current Start layout in .XML file format. e.g. **StartLayoutExported.xml**

Once you have your exported XML, you need to serialize and linearize (suggest using the XML Tools Plugin on Notepad++ to do this quickly or any online tool). Basically you need to convert from XML to Text and remove whitespace. e.g. **StartLayoutSerializedLinearized.txt**

Lastly, you will copy your text and paste it within the `<Data> </Data>` tags.


## Change Log
- 6/8/2017: Created Samples for StartLayout CSP


## Additional Resources
* [Windows 10 Configuration Service Provider Reference](http://aka.ms/CSPList)
* [StartLayout CSP Reference](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-configuration-service-provider#start-startlayout)
* [How to Export Start Layout](https://docs.microsoft.com/en-us/windows/configuration/customize-windows-10-start-screens-by-using-mobile-device-management)