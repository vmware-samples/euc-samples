# Returns used virutal memory in kilobytes
# Return Type: Integer
# Execution Context: User
$os=Get-WmiObject win32_OperatingSystem
$used_memory=$os.totalvirtualmemorysize - $os.freevirtualmemory
echo $used_memory

