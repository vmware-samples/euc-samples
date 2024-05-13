# EUC-samples is now hosted https://github.com/euc-oss/euc-samples.
# This repo is no longer maintained.

# Get App and Process Details

This is a helper for the Workspace ONE Intelligent Hub for macOS feature for blocking apps and processes. 

[VMware Docs for Apps and Process Restrictions for macOS](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/macOS_Platform/GUID-1457AF26-9546-49E5-8D63-6D9162604456.html?hWord=N4IghgNiBcIEoFMDOAXATgSwMYoAQFswsB5AZVwEEAHKibMFDAewDslcAyXABTSa2RJkIAL5A) 

## Installation

Download the appblocker.py script. 

## Usage

```shell
python3 appblock.py --list
```
```shell
python3 appblock.py --app /System/Applications/Podcasts.app
```
--List will show you an output of all installed applications on your Mac, under /Applications, /System/Applications and /System/Applications/Utilities. 

--apps "application path" will show the details required to populate the Custom XML payload to set up the App and Process blocking feature. 

## Output 

```shell
% python3 appblock.py --app /System/Applications/Podcasts.app
Name: Podcasts
File Path: /System/Applications/Podcasts.app/Contents/MacOS
CD Hash: e16e4dd06ea262216f169400e69ab163b26c7849
Team ID: not set
SHA-265:  9bc8af16ae3d7dfdc6b8f795e36385b8fed206205725c4506020a64156ccf0d0
Bundle ID: com.apple.podcasts
```
## Contributing
Changes and improvements welcome. Please follow the VMware Contribution guide for this repository. 

## License
[BSD 3-Clause License](https://github.com/vmware-samples/euc-samples/blob/master/LICENSE)