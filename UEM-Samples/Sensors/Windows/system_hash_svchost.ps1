# Description: Returns the file hash using MD5 Algorithm
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING
# V@riables: folder,[Environment]::SystemDirectory; file,svchost.exe
# future to add ability to use variables.

$file = "svchost.exe"
$folder = [Environment]::SystemDirectory
$md5=Get-FileHash ($folder + "\" + $file) -Algorithm MD5
Return $md5.Hash

