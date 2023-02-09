# Description: Returns used virtual memory (in GB)
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$os=Get-WmiObject win32_OperatingSystem
$used_memory=((($os.totalvirtualmemorysize)/1MB) - (($os.freevirtualmemory)/1MB)).ToString("0.0")
Return "$used_memory GB"

