REM bpeppin, www.brookspeppin.com
REM For use with WS1 Products (which run in 32bit). 
cd %~dp0
%WINDIR%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file .\WS1-ReEnroll.ps1 -Server ds1234.awmdm.com -LGName staging -Username staging@staging.com -Password 123456 -Unenroll OnSIDMismatch

REM If you have a 64 bit delivery mechanism, then drop "%WINDIR%\Sysnative\WindowsPowerShell\v1.0\" prefix, like below 
REM powershell.exe -executionpolicy bypass -file .\WS1-ReEnroll.ps1 -Server ds1234.awmdm.com -LGName staging -Username staging@staging.com -Password 123456 -Unenroll OnSIDMismatch