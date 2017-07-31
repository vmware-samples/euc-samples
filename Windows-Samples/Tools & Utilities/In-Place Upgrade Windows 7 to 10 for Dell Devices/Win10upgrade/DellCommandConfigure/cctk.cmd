@ECHO OFF
 
set cmdline=%*
 
ECHO == Seting BIOS Settings ==
 
REM Determine Arch
IF "%PROCESSOR_ARCHITECTURE%" == "AMD64" GOTO :X64
GOTO X86
 
:X64
SET CCTKPath="x86_64"
GOTO RunCCTK
 
:X86
SET CCTKPath="x86"
GOTO RunCCTK
 
:RunCCTK
ECHO --Running command %CCTKPath%\cctk.exe %CMDLINE%
%CCTKPath%\cctk.exe %CMDLINE%
 
EXIT /B %errorlevel%