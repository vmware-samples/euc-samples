@echo off
REM Determine Arch
IF "%PROCESSOR_ARCHITECTURE%" == "AMD64" GOTO :X64
GOTO X86
 
:X64
x86_64\hapi\hapint.exe -i -k C-C-T-K -p "hapint.exe"
GOTO END
 
:X86
x86\hapi\hapint.exe -i -k C-C-T-K -p "hapint.exe"
GOTO END
 
:END