# Description: Returns True/False if specified process is running
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$process = Get-Process TaskScheduler -ea SilentlyContinue
if($process)
{Return $true}
else
{Return $false}

