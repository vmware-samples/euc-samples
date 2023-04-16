# SurfaceHub CSP

## Overview
- **Author**: Varun Murthy
- **Email**: vmurthy@vmware.com
- **Date Created**: 6/8/2017
- **Supported Platforms**: Surface Hub
- **Tested on Windows 10**: 1607, 1703

## Purpose 
This folder has mutiple configurations that can be applied to SurfaceHubs that will help manage them through OMA-DM via AirWatch.
The [SurfaceHub CSP](https://docs.microsoft.com/en-us/windows/client-management/mdm/surfacehub-csp) is a service provider that is specific to Microsoft Surface Hub hardware and will not apply to other device types. 
This CSP can be used for a variety of configurations like configuring Friendly names, sleep timeout, session timeout, OMS keys, O365 accounts etc.

Please **Note** that many other Windows configurations can be applied to the SurfaceHub as well. Please see [this](https://docs.microsoft.com/en-us/windows/client-management/mdm/configuration-service-provider-reference#a-href-idsurfacehubcspsupportacsps-supported-in-microsoft-surface-hub) list for all supported policies. You will find samples for these other configurations in the parent Windows-samples folder.

## Required Changes/Updates
Most of these examples can be used directly. If you would like to change the behavior please refer to the CSP reference and update the `<Data> </Data>` tag with the right value.

## Caveats
The Wallpaper path in the Wallpaper change sample requires the file to be a PNG file and the URL must end with the .png extension for it to work.

## Change Log
- 6/8/2017: Posted Samples for SurfaceHub CSP

## Additional Resources
* [Windows 10 Configuration Service Provider Reference](http://aka.ms/CSPList)
* [SurfaceHub CSP Reference](https://docs.microsoft.com/en-us/windows/client-management/mdm/surfacehub-csp)
* [Supported Policies on SurfaceHub](https://docs.microsoft.com/en-us/windows/client-management/mdm/configuration-service-provider-reference#a-href-idsurfacehubcspsupportacsps-supported-in-microsoft-surface-hub)