# Description: Delete all Java versions
# Execution Context: System
# Execution Architecture: EITHER64OR32BIT
# Timeout: 30

$JavaInstalled = (Get-WmiObject Win32_Product -Filter 'name like "java%"')
if ($JavaInstalled -ne $null){
  (Get-WmiObject Win32_Product -Filter 'name like "java%"').Uninstall()
} else {
}
