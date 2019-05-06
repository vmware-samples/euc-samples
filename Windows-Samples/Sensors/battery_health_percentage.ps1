# Returns the battery health as a percentage based on designed and actual capacity
# Return Type: Integer
# Execution Context: System
$max_capacity = (Get-WmiObject -Class “BatteryFullChargedCapacity” -Namespace “ROOT\WMI”).FullChargedCapacity | Measure-Object -Sum | Select-Object -ExpandProperty Sum
$design_capacity = (Get-WmiObject -Class “BatteryStaticData” -Namespace “ROOT\WMI”).DesignedCapacity | Measure-Object -Sum | Select-Object -ExpandProperty Sum
$health = ($max_capacity/$design_capacity) * 100
write-output ([System.Math]::Round($health))