# Factory Provisioning for VMware Workspace ONE Scripts

## Overview
- **Authors**: Josue Negron, Brooks Peppin
- **Email**: jnegron@vmware.com, bpeppin@vmware.com
- **Date Created**: 12/18/2018
- **Supported Platforms**: Workspace ONE 1811
- **Tested on**: Windows 10 Pro/Enterprise 1803+

## Purpose
These Factory Provisioning for VMware Workspace ONE samples contain PowerShell command lines or Batch scripts that can be used in the configuration file (unattend.xml) generation step in the Workspace ONE UEM Console. Navigate to **Devices > Lifecycle > Staging > Windows**, select **New** and you can leverage these samples in the **Additional Synchronous Commands** OR **First Logon Commands** fields. 

## Description 
**Additional Synchronous Commands** are commands that automatically run at the end of the Windows setup process but before any user logs in while **First Logon Commands** are commands that automatically run the first time a user logs in. **First Logon Commands** require the first user to login have local admin privileges. 

## Additional Resources
- [Factory Provisioning for VMware Workspace ONE Operational Tutorial](https://techzone.vmware.com/dell-provisioning-vmware-workspace-one-operational-tutorial)
- [VMware Docs](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/1811/Dell-Provisioning-for-VMware-Workspace-ONE/GUID-AWT-DELLPROVISIONING.html)
