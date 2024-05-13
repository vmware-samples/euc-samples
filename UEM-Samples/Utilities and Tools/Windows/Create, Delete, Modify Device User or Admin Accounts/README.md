# EUC-samples is now hosted https://github.com/euc-oss/euc-samples.
# This repo is no longer maintained.

# Create, Delete, Modify Users and Permissions

## Overview
- **Author**: Josue Negron
- **Email**: jnegron@vmware.com
- **Date Created**: 8/1/2017
- **Supported Platforms**: Windows 7/8.1/10
- **Tested on Windows 10**: 1703

## Purpose 
These sets of sample BATCH files will add and delete users and create and downgrade admins. 

- **CreateAdmin.bat** - Creates a local admin on the device
- **CreateUser.bat** - Creates a local user on the device
- **DeleteUser.bat** - Deletes a local user or admin on the device
- **DowngradeAdmin.bat** - Removes user/admin from a group e.g. administrators group

## Details
For more information regarding using the Net User command please refer to the [Net User Reference](https://technet.microsoft.com/en-us/library/cc771865(v=ws.11).aspx). You can modify these scripts to support working with domain users by simply adding the **/domain** parameter. 

Deploy the .bat file via AirWatch's Product Provisioning.

## Change Log
- 8/1/2017: Created Samples for creating/deleting/modifying users and their permissions

## Additional Resources
* [Net User Reference](https://technet.microsoft.com/en-us/library/cc771865(v=ws.11).aspx)
