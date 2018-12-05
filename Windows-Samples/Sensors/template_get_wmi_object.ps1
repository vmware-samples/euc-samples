# Returns the value of a WMI Query 
# Return Type: Depends (String, Boolean, Integer, DateTime)
# Execution Context: Depends (Admin, System, or User)
# More details on how to use Get-WmiObject here: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-wmiobject
$wmi=(Get-WmiObject WMI_Class_Name)
write-output $wmi.Attribute_Name