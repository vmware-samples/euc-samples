# Returns used phsyical memory in kilobytes
# Return Type: Integer
# Execution Context: User
$os = Get-WmiObject win32_OperatingSystem
$used_memory = $os.totalvisiblememorysize - $os.freephysicalmemory
write-output $used_memory

