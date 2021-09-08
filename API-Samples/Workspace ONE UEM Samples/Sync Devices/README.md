# Workspace ONE UEM Device Sync

## SYNOPSIS
This script is useful for initiating a sync from the client application to the Workspace ONE UEM application server (Device Services). There are two ways in which the script can be executed; ad-hoc with a menu, and on a recurring schedule without a menu.

## DESCRIPTION
Within the 'WithMenu' folder, the SyncDevices-Menu.ps1 file can be use on an ad-hoc basis. This script will require manually entering the API Key, Workspace ONE UEM API Endpoint URL, and credentials to authenticate against the API. The script can be executed by double clicking the file within a Windows GUI, or from command line interace.

Within the 'TaskScheduler' folder, the SyncDevices-TaskScheduler.ps1 file can be used within Windows Task Scheduler and executed on a recurring basis. This script will require a one-time setup within the config.ini file. The config.ini file will require the manual entry of the API Key, Workspace ONE UEM API Endpoint URL, and base64 encoded credentials to authenticate against the API. The script can be executed by double clicking SyncDevices-TaskScheduler.ps1 file within a Windows GUI, or by command line interace, or by scheduling a recurring task in Windows Task Scheduler. If the account used to run the script is locked out, or the password has rotated; the base64 encoded credential will require update in the config.ini file. To retrieve the base64 encoded credential; an optional script is included, base64.ps1.

---

## GETTING STARTED

For use with SyncDevices-Menu.ps1

1. Copy the script to destination
2. Double click the file SyncDevices-Menu.ps1
3. Provide the Workspace ONE UEM URL in the following format:
https://server.domain.com
4. Provide the API Key
5. Provide the credentials


For use with SyncDevices-TaskScheduler.ps1

1. Copy the script to destination
2. Open config.ini
3. Paste in API Key, base64 encoded credentials, and Workspace ONE UEM URL. The Workspace ONE UEM URL should be in the following format:
https://server.domain.com
4. Open Windows Task Scheduler
5. Click 'Create Task'
6. Provide a name for the task, specify 'Run whether user is logged on or not'
7. Click 'Actions', followed by 'New'
8. Specify the SyncDevices-TaskScheduler.ps1 in 'Program/script' and click 'OK'
9. Click 'Triggers', followed by 'New'
10. Specify the frequency required and ensure 'Enabled' is checked
11. Click 'OK', followed by 'OK'

---

## OUTPUTS
There are no outputs

---

## NOTES

* Version:        1.0
* Creation Date:  09/03/2021
* Author:         Ryan Pringnitz - rpringnitz@vmware.com
* Author:         Made with love in Kalamazoo, Michigan
* Purpose/Change: Initial Release