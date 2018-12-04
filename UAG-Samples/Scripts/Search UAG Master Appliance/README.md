# Search for the VMware Unified Access Gateway Master Appliance

## Overview
- **Author**: Andreano Lanusse
- **Email**: alanusse@vmware.com
- **Date Created**: 11/04/2018
- **Supported Platforms**: Unified Access Gateway 3.4 and above 

## Purpose 
This script search for the Master appliance in a given Unified Access Gateway Cluster,
it leverage the Unified Access Gateway REST API to obtain the High Availability state of the appliance and identity the Master.

## Requirements
 
In order to execute this script successfully you need to:
1. Unified Access Gateway Admin credentials
2. List of FQDN or IP address (Management NIC) for the Unified Access Gateways appliances.

## How to execute the script

Execute searchUAGMaster.ps1 using the following parameters:

- **–username** – Username for the admin user authorized to login into the Appliances
- **-password** – Password of the given username
- **-UAGAppliancesFQDNorIP** – List of Unified Access Gateways FQDN or IP address used by the Management NIC, all separated by comma

Notes:

- **1** – The credentials that will be used to execute the script must be created in all the appliances.
- **2** – You can mix and match FQDN and IP address on the same command line.

Example:

.\searchUAGMaster.ps1 -username admin -password 4jd9nf9fj -UAGAppliancesFQDNorIP uag1.company.com, uag2.company.com, uag3.company.com, uag4.company.com

.\searchUAGMaster.ps1 -username admin -password 4jd9nf9fj -UAGAppliancesFQDNorIP 192.168.100.11, 192.168.100.12, 192.168.100.13, 192.168.100.14

## Change Log


## Additional Resources
* [Unified Access Gateway Documentation](https://docs.vmware.com/en/Unified-Access-Gateway/)
