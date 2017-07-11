# Office CSP

## Overview
- **Author**: Josue Negron
- **Email**: jnegron@vmware.com
- **Date Created**: 7/11/2017
- **Supported Platforms**: Windows 10 Pro, Enterprise and Education
- **Tested on Windows 10**: 1703

## Purpose 
The [Office CSP](https://docs.microsoft.com/en-us/windows/client-management/mdm/office-csp) is used to install the Office client on a device via the Office Deployment Tool. This CSP was added in Windows 10 1703. 

## Details
The [Office CSP ](https://docs.microsoft.com/en-us/windows/client-management/mdm/office-csp) is the ability to remotely execute a PC Refresh (via MDM) which users can do manually on their device by going to **Settings > Update & Security > Recovery > Reset this PC > Get Started**, then you are presented with **Keep my Files** or **Remove Everything**. This best explains the differences between Retaining User Data and without Retaining User Data. 

A sample configuration XML for deploying Office 365 for Business Retail is below, but you can also use [Configuration XML Editor](https://officedev.github.io/Office-IT-Pro-Deployment-Scripts/XmlEditor.html) to quickly generate this XML, then serialize the XML (using XML Tools Plugin on Notepad++ or any online tool) before pasting between the <data></data> tags in the custom XML sample.

### Configuration XML for Office 365 for Business, Current Channel
    <Configuration>
    	<Add OfficeClientEdition="32" Channel="Current">
    		<Product ID="O365BusinessRetail">
    			<Language ID="en-us" />
    		</Product>
    	</Add>
    	<Display Level="None" AcceptEULA="TRUE" />
    </Configuration>

### Serialized Configuration
    &lt;Configuration&gt;
    	&lt;Add OfficeClientEdition=&quot;32&quot; Channel=&quot;Current&quot;&gt;
    		&lt;Product ID=&quot;O365BusinessRetail&quot;&gt;
    			&lt;Language ID=&quot;en-us&quot; /&gt;
    		&lt;/Product&gt;
    	&lt;/Add&gt;
    	&lt;Display Level=&quot;None&quot; AcceptEULA=&quot;TRUE&quot; /&gt;
    &lt;/Configuration&gt;

## Change Log
- 7/11/2017: Created Sample for Office CSP


## Additional Resources
* [Windows 10 Configuration Service Provider Reference](http://aka.ms/CSPList)
* [Office CSP Reference](https://docs.microsoft.com/en-us/windows/client-management/mdm/office-csp)
* [Configuration Options for the Office Deployment Tool](https://technet.microsoft.com/en-us/library/jj219426.aspx)
* [Configuration XML Editor](https://officedev.github.io/Office-IT-Pro-Deployment-Scripts/XmlEditor.html)
