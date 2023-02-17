# Description: Returns value data for the Reg Key
# Execution Context: SYSTEM | USER
# Execution Architecture: EITHER64OR32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY
# Return Type: STRING | BOOLEAN | INTEGER | DATETIME

$reg=Get-ItemProperty "HKLM:\Key Folder\Key Name"
return $reg.ValueName