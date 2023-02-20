# Description: Returns the max clock speed of the CPU.
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: INTEGER

$cpu = (Get-WmiObject -Class Win32_Processor).MaxClockSpeed
Return $cpu
