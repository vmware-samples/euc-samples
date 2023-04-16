# Returns Total Physical Memory in GB
# Return Type: Integer
# Execution Context: System 
# Execution Architecture: Auto
$totalphysicalmemory = (Get-WmiObject -Class win32_computersystem).TotalPhysicalMemory
$ram = [int]($totalphysicalmemory /1GB)
return $ram