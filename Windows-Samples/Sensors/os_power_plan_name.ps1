# Returns the name of the Power Plan
# Return Type: String
# Execution Context: Admin
$powerplan=get-wmiobject -namespace "root\cimv2\power" -class Win32_powerplan | where {$_.IsActive}
echo $powerplan.ElementName