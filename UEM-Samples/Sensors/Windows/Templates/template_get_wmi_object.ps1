# Description: Returns the value of a WMI Query. More details on how to use Get-WmiObject here: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-wmiobject
# Execution Context: SYSTEM | USER
# Execution Architecture: EITHER64OR32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY
# Return Type: STRING | BOOLEAN | INTEGER | DATETIME

$wmi=(Get-WmiObject WMI_Class_Name)
return $wmi.Attribute_Name