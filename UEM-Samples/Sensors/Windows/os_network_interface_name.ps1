# Returns the name (description) of the active network interface
# Return Type: String
# Execution Context: User
$properties = @(‘Name’,’InterfaceDescription’)
$physical_adapter = get-netadapter -physical | where status -eq "up" |select-object -Property $properties
write-output $physical_adapter.InterfaceDescription

