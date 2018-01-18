

REM Open the firewall to allow incoming connections
netsh advfirewall firewall set rule group="Remote Desktop" new enable=Yes

REM Disable "Deny TS Connections" registry key
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

REM Set service to start automatically at boot 
sc config termservice start= auto

REM Start service
net start termservice