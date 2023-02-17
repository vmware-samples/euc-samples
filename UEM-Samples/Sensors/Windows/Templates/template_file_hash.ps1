# Description: Returns the file hash using MD5 Algorithm
# Execution Context: SYSTEM | USER
# Execution Architecture: EITHER64OR32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY
# Return Type: INTEGER

$file=Get-FileHash ([Environment]::SystemDirectory + “\svchost.exe”) -Algorithm MD5
return $file.Hash