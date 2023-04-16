# Maintain Workspace ONE Co-existence with SCCM Compliance Rule

## Overview

* Author: Brooks Peppin
* Email: bpeppin@vmware.com
* Date Created: 5/20/2019
* Tested On: Windows 10 1803, SCCM 1802 and AirWatch 19.4

## Description
How you can use an SCCM compliance baseline to check for valid enrollment and if it fails, run a script to remove old agent, repair WMI, re-enroll automatically. 

## Instructions
There are several steps to the staging process:

1. Download all files: Re-Enroll WS1 Package.zip, Re-Enroll-WS1.ps1, WS1 Enrollment Baseline.cab, AirwatchAgent.msi from https://getwsone.com
2. Import SCCM Baseline
3. Create folder on SCCM application repo with Re-Enroll-WS1.ps1 and AirwatchAgent.msi
4. Import SCCM Package. Update package to reflect your SCCM package content path you created in previous step.
5. Assign Baseline to collection. Create a new collection based off of "non-compliant" results.
6. Deploy package to non-compliant collection.

See blog for full walk-through

