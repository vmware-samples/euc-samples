# Description: Returns True if any threat is detected and status is OfflineScanRequired
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

$defender=((Get-MpThreatDetection | Where ThreatID -In (Get-MpThreat | Where IsActive -EQ $true | Select-Object -Property ThreatId).ThreatId | Where AdditionalActionsBitMask -ge 32768) | Measure).Count -GT 0
return $defender
