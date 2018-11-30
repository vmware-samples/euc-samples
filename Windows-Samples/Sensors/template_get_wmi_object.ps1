# Returns the value of a WMI Query 
# Return Type: Depends
# Execution Context: Depends
# More details on how to use Get-WmiObject here: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-wmiobject
$wmi=(Get-WmiObject WMI_Class_Name)
write-output $wmi.Attribute_Name