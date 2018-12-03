<# Returns the system type. For example: 
    "x64-based PC"
    "X86-based PC"
    "MIPS-based PC"
    "Alpha-based PC"
    "Power PC"
    "SH-x PC"
    "StrongARM PC"
    "64-bit Intel PC"
    "64-bit Alpha PC"
    "Unknown"
    "X86-Nec98 PC"  #>
# Return Type: String
# Execution Context: User
$computer = Get-WmiObject -Class Win32_ComputerSystem 
write-output $computer.SystemType