# Description: Returns the CPU Architecture. Returns X86 | X64 | ARM64
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$cpuarchitecture = (Get-WmiObject -Class Win32_Processor).Architecture
if($cpuarchitecture -eq 0) {
  return "X86"
} elseif($cpuarchitecture -eq 9) {
  return "X64"
} elseif($cpuarchitecture -eq 12) {
  return "ARM64"
}
