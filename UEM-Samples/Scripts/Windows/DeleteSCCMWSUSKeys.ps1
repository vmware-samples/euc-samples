# Description: Deletes the SCCM WSUS registry keys that prevent a Windows 10 machine from using a modern managed Windows Update Profile. 
# Once deleted the machine will honour the WS1 delivered WUS or WSUS configuration settings.
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Timeout: 30
# Variables: RegPath,"HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"; Regkey1,"WUServer"; Regkey2,"WUStatusServer"

Remove-ItemProperty -Path $env:RegPath -Name $env:Regkey1
Remove-ItemProperty -Path $env:RegPath -Name $env:Regkey2
