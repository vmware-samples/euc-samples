# Enrollment Troubleshooting Tool

## Overview
- **Author**: Mike Nelson
- **Email**: miken@vmware.com
- **Date Created**: 08/28/2018
- **Tested on Windows 10 1709, 1803**: Completed

## SYNOPSIS
This Powershell script allows you to quickly check a device for the required services and network connections required for MDM enrollment.

## DESCRIPTION
When run, if command line parameters are not provided, this script collect the required data and display it on the Powershell screen. The script can generate an HTML report for easier review and also collect the logs in the same location as the report to make sharing the information easier.

## EXAMPLE

    .\EnrollmentChecker

    .\Enrollment-Checker -generateHTMLReport

    .\Enrollment-Checker -generateHTMLReport -showReport

    .\Enrollment-Checker -collectLogs

    .\Enrollment-Checker -generateHTMLReport -collectLogs

## Parameters

**generateHTMLReport**
Generates an HTML report of the gathered information and marks items in red that need to be addressed in order for Enrollment to work correctly.

**showReport**
Immediately opens the report in a browser for review

**collectLogs**
Collects Agent logs to the script's output directory.