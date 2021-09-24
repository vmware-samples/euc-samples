# Returns the current O365 Version
# Execution Context: System
$key = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
$subKey = $key.OpenSubKey("SOFTWARE\Microsoft\Office\ClickToRun\Configuration")
$regkey_value = $subKey.GetValue("ClientVersionToReport")
return $regkey_value
