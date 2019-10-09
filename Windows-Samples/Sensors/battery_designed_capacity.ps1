# Returns the max charge capacity of the batteries
# Return Type: Integer
# Execution Context: System
$design_capacity = (Get-WmiObject -Class “BatteryStaticData” -Namespace “ROOT\WMI”).DesignedCapacity | Measure-Object -Sum | Select-Object -ExpandProperty Sum
write-output $design_capacity