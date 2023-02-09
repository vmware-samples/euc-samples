# Description: Returns the number of logical processors. Logical processors are number of physical CPUs * number of cores per CPU
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: INTEGER

$cpus = (Get-WmiObject -Class win32_computersystem).NumberofLogicalProcessors
return $cpus

