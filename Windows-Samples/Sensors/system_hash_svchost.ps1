# Returns the file hash using MD5 Algorithm
# Return Type: String
# Execution Context: System
$file=Get-FileHash ([Environment]::SystemDirectory + “\svchost.exe”) -Algorithm MD5
Write-Output $file.Hash