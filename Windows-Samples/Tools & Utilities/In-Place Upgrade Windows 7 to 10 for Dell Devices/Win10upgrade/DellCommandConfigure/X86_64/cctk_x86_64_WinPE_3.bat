@echo off
:: ***************************************************************************
:: *                         WARRANTY DISCLAIMER
:: ***************************************************************************
:: * THIS SCRIPT IS BEING PROVIDED TO YOU "AS IS".  DELL DISCLAIMS ANY
:: * AND ALL WARRANTIES, EXPRESS, IMPLIED OR STATUTORY, WITH RESPECT TO THE
:: * SCRIPT, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
:: * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE AND ANY WARRANTY
:: * OF NON-INFRINGEMENT. YOU WILL USE THIS SCRIPT AT YOUR OWN RISK.
:: * DELL SHALL NOT BE LIABLE TO YOU FOR ANY DIRECT OR INDIRECT DAMAGES
:: * INCURRED IN USING THE SCRIPT. IN NO EVENT SHALL DELL OR ITS
:: * SUPPLIERS BE RESPONSIBLE FOR ANY DIRECT OR INDIRECT DAMAGES WHATSOEVER
:: * (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, LOSS OF USE,
:: * LOSS OF DATA, BUSINESS INTERRUPTION, OR OTHER PECUNIARY LOSS, NOR FOR
:: * PUNITIVE, INCIDENTAL, CONSEQUENTIAL, OR SPECIAL DAMAGES OF ANY KIND,
:: * UNDER ANY PART OF THIS AGREEMENT, EVEN IF ADVISED OR AWARE OF THE
:: * POSSIBILITY OF SUCH DAMAGES).
:: ***************************************************************************

:: ***************************************************************************
REM Name: cctk_x86_64_winpe_3.bat
REM
REM Purpose:
REM    This script installs Dell drivers into a base Windows PE 3.0 image offline.
REM  
REM Arguments:
REM    %1 Path to local directory for Windows PE 3.0 image to create
REM    %2 Path to extracted Command Configure toolkit

:: ***************************************************************************
if "%1%" == "" goto usage

if "%2%" == "" goto usage


@echo -------------------------------------
@echo Setup a WinPE 3.0 build environment
@echo -------------------------------------

Set AIKTOOLS="C:\Program files\Windows AIK\Tools"
::Set AIKTOOLS=C:\winsevaik\Tools
@echo ----------------------------------------
@echo (cctk_x86_64_winpe.bat)-Check the Paths
@echo ----------------------------------------

if not exist %2% (
	echo CCTKPATH %2% does not exist. Exiting.....
	goto done
)

if not exist %AIKTOOLS% (
	echo %AIKTOOLS%  does not exist.
	echo please set the right path for the variable AIKTOOLS before running this script
	echo if its a long path please make sure its specified in quotes
	echo for eg: Set AIKTOOLS="C:\Program files\Windows AIK\Tools"
	goto done
)

Set WINPEPATH=%1%
Set CCTKPATH=%2%

::rd /s/q %WINPEPATH%

if not exist %WINPEPATH% call %AIKTOOLS%\PETools\copype.cmd amd64 %WINPEPATH%



%AIKTOOLS%\x86\imagex /apply %WINPEPATH%\WinPE.wim 1 %WINPEPATH%\mount

@echo ------------------------------------
@echo Add additional customizations
@echo ------------------------------------

%AIKTOOLS%\Servicing\dism.exe  /image=%WINPEPATH%\mount /Add-Package /PackagePath:%AIKTOOLS%\PETools\amd64\WinPE_FPs\winpe-fontsupport-ja-jp.cab
%AIKTOOLS%\Servicing\dism.exe  /image=%WINPEPATH%\mount /Add-Package /PackagePath:%AIKTOOLS%\PETools\amd64\WinPE_FPs\winpe-fontsupport-zh-cn.cab
%AIKTOOLS%\Servicing\dism.exe  /image=%WINPEPATH%\mount /Add-Package /PackagePath:%AIKTOOLS%\PETools\amd64\WinPE_FPs\winpe-wmi.cab
%AIKTOOLS%\Servicing\dism.exe  /image=%WINPEPATH%\mount /Add-Package /PackagePath:%AIKTOOLS%\PETools\amd64\WinPE_FPs\winpe-scripting.cab
%AIKTOOLS%\Servicing\dism.exe  /image=%WINPEPATH%\mount /Add-Package /PackagePath:%AIKTOOLS%\PETools\amd64\WinPE_FPs\winpe-wds-tools.cab
 


@echo --------------------------------------------------------------
@echo ~~5 -Copy HAPI and TOOLKIT Files to the mounted image 6
@echo --------------------------------------------------------------

::copy /Y %CCTKPATH%\*.dll    %WINPEPATH%\mount\Command_Configure\X86_64\HAPI
::xcopy %CCTKPATH%\HAPI\*.*    %WINPEPATH%\mount\Command_Configure\X86_64\HAPI /S /E /i /Y
xcopy %CCTKPATH%\X86_64\HAPI\*.*    %WINPEPATH%\mount\Command_Configure\X86_64\HAPI /S /E /i /Y
xcopy %CCTKPATH%\X86_64\*.*	   %WINPEPATH%\mount\Command_Configure\X86_64 /S /E /i /Y
rem copy /Y %CCTKPATH%\Readme.txt    %WINPEPATH%\mount\Command_Configure\X86_64



@echo ------------------------
@echo Add the Services
@echo ------------------------
echo echo Starting WMI Services >> %WINPEPATH%\mount\windows\system32\STARTNET.CMD
echo net start winmgmt >> %WINPEPATH%\mount\windows\system32\STARTNET.CMD
echo echo ******************** >> %WINPEPATH%\mount\windows\system32\STARTNET.CMD
echo echo Installing HAPI >> %WINPEPATH%\mount\windows\system32\STARTNET.CMD
echo X:\Command_Configure\X86_64\HAPI\hapint -i -k C-C-T-K -p X:\Command_Configure\X86_64\HAPI\ >> %WINPEPATH%\mount\windows\system32\STARTNET.CMD
echo echo Successfully Installed the HAPI Drivers >> %WINPEPATH%\mount\windows\system32\STARTNET.CMD
echo echo *********************>> %WINPEPATH%\mount\windows\system32\STARTNET.CMD

@echo --------------------------------------
@echo Prepare the image for deployment 
@echo --------------------------------------

if not exist %WINPEPATH%\WIM\ (
 md %WINPEPATH%\WIM\
 )

%AIKTOOLS%\X86\imagex /BOOT /COMPRESS maximum /CAPTURE %WINPEPATH%\mount\ %WINPEPATH%\WIM\boot.wim "Command Configure WinPE 3 Image"

@echo ---------------------------------------------
@echo Commit the customization to base image 
@echo ---------------------------------------------

REM move %WINPEPATH%\ISO\sources\boot.wim %WINPEPATH%\boot-base.wim
copy %WINPEPATH%\wim\boot.wim    %WINPEPATH%\wim\cctk_x86_64_pe3.wim
move /Y %WINPEPATH%\wim\boot.wim %WINPEPATH%\ISO\sources\boot.wim
%AIKTOOLS%\x86\oscdimg -n -b%WINPEPATH%\etfsboot.com %WINPEPATH%\ISO %WINPEPATH%\WIM\Command_Configure_x86_64_3.iso

goto done
:usage
echo.
echo cctk_x86_64_winpe_3.bat
echo.
echo Copyright 2009 - 2015 Dell Inc. All rights reserved.
echo.
echo Usage : cctk_x86_64_winpe_3.bat WINPEPATH CCTKPATH
echo.
echo Where:
echo   WINPEPATH   path where the Windows PE 3.0 contents should create
echo   CCTKPATH     path where Command Configure is installed
echo.
echo ***********************************************************************
echo.
echo Please make sure WINPEPATH should be a new folder everytime when run 
echo this script.
echo .
echo Please use short path for both parameters, to use long path
echo please hardcode this value in to the batch file
echo.
echo ***********************************************************************
echo.
echo Example: cctk_x86_64_WinPE_3.bat C:\winsevpe_x64 C:\Progra~2\Dell\Comman~1\
echo This installs the HAPI (Instrumentation)
echo drivers found in the C:\Progra~2\Dell\Comman~1\X86_64\HAPI folder to the base
echo Windows PE image in C:\winsevpe_x64.
echo.
echo NOTE: If any of these drivers are already present in the Windows PE Image,
echo       then this script overwrites them.
echo.
echo.

goto done
:done
@echo -------------------------------
@echo (cctk_x86_64_winpe.bat)-DONE.
@echo -------------------------------
set WINPEPATH=
set CCTKPATH=
set AIKTOOLS=
echo.
