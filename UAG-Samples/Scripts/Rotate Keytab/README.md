# Automating rotation of keytab on Unified Access Gateway for Identity Bridging Use Cases

## Overview
- **Author**: Andreano Lanusse
- **Email**: alanusse@vmware.com
- **Date Created**: 10/14/2019
- **Supported Platforms**: Unified Access Gateway 3.7 and above 

## Purpose 
This script automated the process of rotating keytab files on Unified Access Gateway, including create new keytabs and update related IIS configurations.

The script will perform the following operations:
- Create a keytab file and update service account password using ktpass
- Upload keytab file to Unified Access Gateway using REST API 
- Update IIS Application Pool Identity with new credentials
- Reset IIS

After successfully execute the script, the Web Reverse Proxy instances configured on Unified Access Gateway and associated with the keytab SPN will restart to establish a new connection with the KDC based on the new keytab, after that the internal web applications will be available to the external users.

## Requirements
 
To execute this script successfully, you need to:
1. Download the uagkeytabrotate.psm1 and runsample.ps1 script files into a local folder on the IIS Server hosting the internal website frontend by Unified Access Gateway
2. Import the module using the following PS command Install-Module .\uagkeytabrotate.psm1

The module contains the following commands:

- **New-Keytabfile** - generate new keytab files based on the informed parameters, behind the scene it uses the ktpass utility   

- **Connect-UAG** - Validate the connection with UAG and obtain authorization token to use with the other UAG related commands.

- **Get-Keytabs** - return the list of SPNs available on UAG

- **Import-Keytab** - upload the new keytab file to UAG

- **Update-IIS** - update the DefaultAppPool identity with the new credentials and reset IIS - The Application Pool Name can be overriden using the parameter -appPoolName  

## How to execute the script

Launch a PowerShell console as an administrator user, open the runsample.ps1 file, and update the following variables that will be used by the commands:

- **$spn** - Service Principal Name used to generate the keytab
- **keytabfile** - name of the new keytabfile including the path
- **domain** - domain of the service account
- **username** - username for the service account that password needs to be updated
- **newpassword** - new password for the UAG account 
- **uaguser** - username for the UAG account with admin privileges
- **uagpassword** - password for the UAG account 
- **uaghostname** - UAG instance where keytab rotation will be performed

You need to open the runsample.ps1 file and update the variable values, save and run the script as:

Example:

.\runsample.ps1

Additional details on the concept and use cases to apply this script, check out this blog post on Tech Zone [Automating Keytab Rotation for Identity Bridging on VMware Unified Access Gateway](https://techzone.vmware.com/blog/automating-keytab-rotation-identity-bridging-vmware-unified-access-gateway)



## Change Log


## Additional Resources
* [Unified Access Gateway Tech Zone Learning Path](https://techzone.vmware.com/mastering-unified-access-gateway/)
* [Unified Access Gateway Documentation](https://docs.vmware.com/en/Unified-Access-Gateway/)
