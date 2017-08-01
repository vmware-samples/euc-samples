::reg add <KeyName> [{/v ValueName | /ve}] [/t DataType] [/s Separator] [/d Data] [/f]

@echo off
::Enable Kerberos
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v EnableNegotiate /t REG_DWORD /d 1 /f
::Enable Auto Send UN/PW for Trusted Sites (User Authentication: Logon)
:: Full list of 1A00 meaning and other options please visit: https://support.microsoft.com/en-us/help/182569/internet-explorer-security-zones-registry-entries-for-advanced-users
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" /v 1A00 /t REG_DWORD /d 0 /f 
::Add Sites to Trusted Zone List
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\company.com" /v https /t REG_DWORD /d 2 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\internal.company.com" /v https /t REG_DWORD /d 2 /f  

