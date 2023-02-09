$Name = (Get-WmiObject win32_desktopmonitor).Name
return $Name
