# Workspace ONE UEM Smart Group from CSV

## SYNOPSIS
This script can be used to create a smart group from a CSV file in Workspace ONE UEM. There is one way the script is designed to be executed, and that is by directly calling the script and entering environment and smart group details when prompted.

## DESCRIPTION
The Create-Smartgroup.ps1 file can be use on an ad-hoc basis. At script execution, the script will require prompt to manually enter;
- API Key
- Workspace ONE UEM URL
- Organization ID (numeric value)
- Organization Group UUID
- CSV file name
- Credentials to authenticate against the API
- Smart Group Name

The script can be executed by double clicking the file within a Windows GUI, or from command line interace. To assist with first time use, a reference CSV file has been provided, EXAMPLE-CSV.csv. Once the script is executing, it will retrieve all devices from the organization ID provided, retrieve the hostnames from the CSV file, remove duplicate devices in the CSV file (in the event the hostname is listed twice in the CSV file. Requirement for API), identify the Workspace ONE UEM device ID's for each of the hostnames in the CSV file, create the JSON body for the REST API call, and make a REST API call to Workspace ONE UEM to create the smart group.

---

## GETTING STARTED

For use with Create-Smartgroup.ps1

1. Copy the script and CSV file to destination
2. Double click the file Create-Smartgroup.ps1
3. Provide the Workspace ONE UEM URL in the following format:
https://server.domain.com
4. Provide the API Key
5. Provide the credentials
6. Provide the CSV filename
7. Provide the organization group ID
8. Provide the organization group UUID
9. Provide the smart group name

---

## OUTPUTS
(1) Net-new smart group in Workspace ONE UEM

---

## NOTES

* Version:        1.0
* Creation Date:  04/28/2022
* Author:         Ryan Pringnitz - rpringnitz@vmware.com
* Author:         Ty Edwards - edwardsty@vmware.com
* Author:         Alex Chau - achau@vmware.com
* Author:         Made with love in Kalamazoo, Michigan, Fredericksburg, Virginia & Atlanta, Georgia
* Purpose/Change: Initial Release
