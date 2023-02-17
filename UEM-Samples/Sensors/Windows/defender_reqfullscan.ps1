# Description: Returns True if any threat is detected and status requires FullScan, eg. is either "FullScanRequired", "FullScanAndRebootRequired", "FullScanAndManualStepsRequired", "FullScanAndRebootAndManualStepsRequired", "FullScanAndOfflineScanRequired", "FullScanAndManualStepsAndOfflineScanRequired", "FullScanAndRebootAndManualStepsAndOfflineScanRequired"
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

$defender=((Get-MpThreatDetection | Where ThreatID -In (Get-MpThreat | Where IsActive -EQ $true | Select-Object -Property ThreatId).ThreatId | Where AdditionalActionsBitMask -IN @(4,12,20,28,32772,32788,32796)) | Measure).Count -GT 0
return $defender
