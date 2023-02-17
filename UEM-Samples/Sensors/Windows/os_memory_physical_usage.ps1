# Description: Returns physical memory in use (in GB)
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$os = Get-WmiObject win32_OperatingSystem
$used_memory = ((($os.totalvisiblememorysize)/1MB) - (($os.freephysicalmemory)/1MB)).ToString("0.0")
Return "$used_memory GB"

