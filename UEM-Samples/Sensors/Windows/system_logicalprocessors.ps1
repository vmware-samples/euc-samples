# Returns the number of logical processors. Logical processors are number of physical CPUs * number of cores per CPU
# Return Type: Integer
# Execution Context: System 
# Execution Architecture: Auto
$cpus = (Get-WmiObject -Class win32_computersystem).NumberofLogicalProcessors
return $cpus
