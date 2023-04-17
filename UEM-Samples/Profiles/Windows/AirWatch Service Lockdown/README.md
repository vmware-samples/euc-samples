# PRODUCTIZED #

----------

# Prevent AirWatch Service Disablement

## Overview
- **Author**: Josue Negron
- **Email**: jnegron@vmware.com
- **Date Created**: 3/7/2018
- **Supported Platforms**: AirWatch 9.2.2+ and AirWatch Agent 9.2+
- **Tested on Windows 10**: 1703, 1709

## Purpose 
Prevent end users from changing the AirWatch service properties on their devices with a Windows Desktop Custom Settings Profile. For devices that already have local changes, the profile resets the device to the default values and locks those settings from further changes.

## Details
1. Navigate to **Add > Profile > Windows > Desktop > Device Profile**.
1. Add General Profile Settings to determine how the profile deploys and who receives it.
1. Select the **Custom Settings** payload and click **Configure**.
1. From the **Target** dropdown menu, select **AirWatch Protection Agent**.
1. Paste the following XML into the text box:
	
	    <wap-provisioningdoc id="c14e8e45-792c-4ec3-88e1-be121d8c33dc" name="customprofile">
    	<characteristic type="com.airwatch.winrt.awservicelockdown" uuid="7957d046-7765-4422-9e39-6fd5eef38174">
    	<parm name="LockDownAwService" value="True"/>
    	</characteristic>
    	</wap-provisioningdoc>


1. Select **Save & Publish**.


1. To remove the restriction from end users devices, push a separate profile using the following code: 
	
	    <wap-provisioningdoc id="c14e8e45-792c-4ec3-88e1-be121d8c33dc" name="customprofile">
    	<characteristic type="com.airwatch.winrt.awservicelockdown" uuid="7957d046-7765-4422-9e39-6fd5eef38174">
    	<parm name="LockDownAwService" value="False"/>
    	</characteristic>
    	</wap-provisioningdoc>
    

## Change Log
- 3/7/2018: Created Sample for AirWatch Service Lockdown


## Additional Resources
* [Blog for AirWatch 9.2.2 and 9.2.3 Feature Updates ](https://blogs.vmware.com/euc/2018/02/deep-dive-latest-workspace-one-features.html)