# Description: Set Registry Key
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Timeout: 30
# Variables: RegPath,"Registry::HKLM:\SOFTWARE\AIRWATCH"; Regkey,"EAUATScript"; RegValue,"UAT Script run in System Context"

Set-ItemProperty -Path $env:RegPath -Name $env:Regkey -Value $env:RegValue
