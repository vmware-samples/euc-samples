# Returns build number e.g. 17134
# Return Type: String
# Execution Context: System
$BuildNumber=(Get-WmiObject Win32_OperatingSystem).Buildnumber
return $BuildNumber