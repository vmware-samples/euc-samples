# Returns the name of the Power Plan
# Return Type: String
# Execution Context: System
$powerplan=get-wmiobject -namespace "root\cimv2\power" -class Win32_powerplan | where {$_.IsActive}
write-output $powerplan.ElementName