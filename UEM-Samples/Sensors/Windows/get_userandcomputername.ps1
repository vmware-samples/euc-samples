# Description: Return current logged in user comma computername
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$domainuser = Get-WmiObject -Class "Win32_ComputerSystem" | select username
$user = ($domainuser.username).Substring($domainuser.username.IndexOf('\')+1)
$computername = Get-WmiObject -Class "Win32_ComputerSystem" | select name

return $user + "," + $computername.Name

