# EUC-samples is now hosted https://github.com/euc-oss/euc-samples.
# This repo is no longer maintained.

# Windows 10 Automated Setup Media

## Overview

* Author: Brooks Peppin
* Email: bpeppin@vmware.com
* Date Created: 1/16/2019
* Date Updated: 8/8/2019
* Tested On: Windows 10 1709, 1803, 1809 Setup Media

## Latest Updates
8/8/19
* Added logic to automatically detect and use an already mounted ISO
* Automatically add the autounattend.xml file at the end of the script
* Update autounattend.xml file to install the version of Windows 10 you selected (i.e. professional or education, etc)

## Description
This script creates automated Windows 10 setup on bootable USB media. It takes any Windows 10 ISO, formats USB to support UEFI NTFS booting, and places autounattend.xml in the root of the drive in order to make it a zero touch setup process.

## Requirements
1. 8 GB or larger USB drive (USB 3.0 recommended)
2. Windows 10 Setup Media in ISO format
3. Script must be run on Windows 10 1803 or newer in order for Windows Explorer to see multiple partitions on the USB drive
4. Target device must be configured to boot in UEFI mode

## Instructions

**Ensure you are on Windows 10 1803 or newer running this script**
 For full, detailed instructions please see this [blog](https://brookspeppin.com/2019/01/12/create-a-zero-touch-windows-10-setup-usb-key/):
Basic Steps: 
1. Download Windows 10 media (ISO) from MSDN or Microsoft Volume License site.
2. Mount ISO in Windows Explorer.
3. Run script (right click powershell script and click "run with powershell"). This script will self-elevate as administrator.
4. Follow prompts on wizard to input mounted ISO drive letter and drive number of USB.
5. The script will get image information on the ISO you select and prompt you which version/index of the image you would like to apply. Select appropriate version. The script will update the autounattend.xml file automatically on your USB accordingly. 
5. Once complete, put usb into laptop (or VM).
6. Boot device and hit correct key to bring up boot menu (F12 on Dell machines, ESC on VMs, other devices might be different).
7. System will boot and automatically format the internal drive and install Windows 10.

*Note: Windows 10 media comes with many different SKUs (Education, Enterprise, etc). If you would like Windows 10 Setup to install a different version, edit the autounattend.xml file in the root of the USB drive and update the name of the SKU you desire in the "ImageInstall" node in the XML. For example, to change from Win10 Pro to Win10 Enterprise you would update the "Value" key to be: <Value>Windows 10 Enterprise</Value>

