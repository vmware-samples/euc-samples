echo off
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
REM Name: cctk_x86_64_winpe_5.bat
REM
REM Purpose:
REM    This script installs Dell drivers into a base Windows PE 5.0 image offline.
REM  
REM Arguments:
REM    %1 Path to local directory for customized Windows PE 5.0 image to create
REM    %2 Path to extracted Command Configure toolkit
REM	Example: cctk_x86_64_WinPE_5.bat C:\Winape_x64 C:\Progra~2\Dell\Comman~1\

:: ***************************************************************************

if "%1%" == "" (
	goto usage
)

if "%2%" == "" (
	goto usage
)
if exist %1% (
	echo Please provide a non-existant folder for 'WINPEPATH'. Exiting.....
	goto usage
)

set CCTKPATH=%2%\X86_64
set WINPEPATH=%1%
set WINPECCTKPATH=%WINPEPATH%\mount\Command_Configure\X86_64

set WinPERoot=C:\Progra~2\Windows Kits\8.1\Assessment and Deployment Kit\Windows Preinstallation Environment
set OSCDImgRoot=C:\Progra~2\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg

set ADKTOOLSROOT=C:\Progra~2\Windows Kits\8.1\Assessment and Deployment Kit
set ADKTOOLS=%ADKTOOLSROOT%\Windows Preinstallation Environment\amd64
set DISM=%ADKTOOLSROOT%\Deployment Tools\amd64\DISM\dism.exe
set IMAGEX=%ADKTOOLSROOT%\Deployment Tools\amd64\DISM\imagex.exe
set STARTNET=%WINPEPATH%\mount\windows\system32\STARTNET.CMD

@echo ----------------------------------------
@echo - 1 (cctk_x86_64_winpe.bat)-Check the Paths
@echo ----------------------------------------

if not exist %2% (
	echo CCTKPATH %2% does not exist. Exiting.....
	goto done
)

if not exist "%ADKTOOLS%" (
	echo %ADKTOOLS%  does not exist. Exiting.....
	goto done
) 


@echo ---------------------------------------
@echo - 2 Setup a WinPE 2.0 build environment
@echo ---------------------------------------
rd /s /q %WINPEPATH%
if not exist %WINPEPATH% call "%ADKTOOLS%\..\copype.cmd" amd64 "%WINPEPATH%"

REM _______________________________________________________
REM copy the files necessary for the Win PE image
REM _______________________________________________________
xcopy /Y %WINPEPATH%\media\*.* %WINPEPATH%\ISO\
xcopy /Y /s %WINPEPATH%\media\boot\*.* %WINPEPATH%\ISO\boot\
xcopy /Y /s %WINPEPATH%\media\en-us\*.* %WINPEPATH%\ISO\en-us\

@echo --------------------------------------------
@echo - 3-Mount the base WinPE Image (winpe.wim) 
@echo --------------------------------------------
REM Mount the base WINPE image (1=Image Number) locally to add or remove packages
REM "%IMAGEX%" /apply "%ADKTOOLS%\en-us\winpe.wim" 1 "%WINPEPATH%\mount"
copy "%ADKTOOLS%\en-us\winpe.wim" %WINPEPATH%\
"%DISM%" /mount-Wim /WimFile:%WINPEPATH%\winpe.wim /index:1 /mountdir:"%WINPEPATH%\mount"
	
@echo --------------------------------------------------------------
@echo - 4 Add additional packages necessary
@echo --------------------------------------------------------------
"%DISM%" /image="%WINPEPATH%"\mount /Add-Package /PackagePath:"%ADKTOOLS%\WinPE_OCs\WinPE-FontSupport-JA-JP.cab"
"%DISM%" /image="%WINPEPATH%"\mount /Add-Package /PackagePath:"%ADKTOOLS%\WinPE_OCs\winpe-fontsupport-zh-cn.cab
"%DISM%" /image="%WINPEPATH%"\mount /Add-Package /PackagePath:"%ADKTOOLS%\WinPE_OCs\winpe-wmi.cab
"%DISM%" /image="%WINPEPATH%"\mount /Add-Package /PackagePath:"%ADKTOOLS%\WinPE_OCs\winpe-scripting.cab
"%DISM%" /image="%WINPEPATH%"\mount /Add-Package /PackagePath:"%ADKTOOLS%\WinPE_OCs\winpe-wds-tools.cab

@echo --------------------------------------------------------------
@echo - 5 Add HAPI and Command Configure
@echo --------------------------------------------------------------
xcopy "%CCTKPATH%\HAPI\*.*"    %WINPECCTKPATH%\HAPI /S /E /i /Y
xcopy "%CCTKPATH%\*.*"	   %WINPECCTKPATH% /S /E /i /Y


@echo ------------------------
@echo - 6 Add the Services
@echo ------------------------
echo echo off>> %STARTNET%
echo echo Starting WMI Services >> %STARTNET%
echo net start winmgmt >> %STARTNET%
echo echo ******************** >> %STARTNET%
echo echo Installing HAPI >> %STARTNET%
echo X:\Command_Configure\X86_64\HAPI\hapint -i -k C-C-T-K -p X:\Command_Configure\X86_64\HAPI\ >> %STARTNET%
echo echo Successfully Installed the HAPI Drivers >> %STARTNET%
echo cd X:\Command_Configure\x86_64>> %STARTNET%
echo echo *********************>> %STARTNET%
@echo --------------------------------------

@echo --------------------------------------
@echo - 7 Prepare the image for deployment 
@echo --------------------------------------
if not exist %WINPEPATH%\WIM\ (
 md %WINPEPATH%\WIM\
 )
"%IMAGEX%" /BOOT /COMPRESS maximum /CAPTURE %WINPEPATH%\mount\ %WINPEPATH%\WIM\boot.wim "Command Configure WinPE 5 Image"

@echo ---------------------------------------------
@echo - 8 Commit the customization to base image 
@echo ---------------------------------------------
REM move %WINPEPATH%\ISO\sources\boot.wim %WINPEPATH%\boot-base.wim
REM copy %WINPEPATH%\wim\boot.wim    %WINPEPATH%\wim\cctk_x86_pe5.wim
md %WINPEPATH%\ISO\sources\

move /Y %WINPEPATH%\wim\boot.wim %WINPEPATH%\ISO\sources\boot.wim
xcopy /s /Y "%OSCDImgRoot%\*" %WINPEPATH%\fwfiles\
"%OSCDImgRoot%\oscdimg.exe" -b%WINPEPATH%\fwfiles\etfsboot.com -n %WINPEPATH%\ISO %WINPEPATH%\WIM\Command_Configure_x86_64_5.iso

@echo ---------------------------------------------
@echo - 9 Unmount the image
@echo ---------------------------------------------

"%DISM%" /Unmount-Wim /mountDir:%WINPEPATH%\mount /discard

goto done
:usage
echo.
echo cctk_x86_64_winpe_5.bat
echo.
echo Copyright 2009 - 2015 Dell Inc. All rights reserved.
echo.
echo Usage : cctk_x86_64_winpe_5.bat WINPEPATH CCTKPATH
echo.
echo Where:
echo   WINPEPATH   path where the Windows PE 5.0 contents should create
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
echo Example: cctk_x86_64_WinPE_5.bat C:\winsevpe_x64 C:\Progra~2\Dell\Comman~1\
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
@echo (cctk_x86_64_winpe_5.bat)-DONE
@echo -------------------------------
set WINPEPATH=
set CCTKPATH=
set AIKTOOLS=
echo.
