# Description: Returns True if any threat is detected and any status requires Reboot, eg. is either "RebootRequired", "FullScanAndRebootRequired", "RebootAndManualStepsRequired", "FullScanAndRebootAndManualStepsRequired", "RebootAndOfflineScanRequired", "FullScanAndRebootAndOfflineScanRequired", "RebootAndManualStepsAndOfflineScanRequired", "FullScanAndRebootAndManualStepsAndOfflineScanRequired"
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$defender=((Get-MpThreatDetection | Where ThreatID -In (Get-MpThreat | Where IsActive -EQ $true | Select-Object -Property ThreatId).ThreatId | Where AdditionalActionsBitMask -IN @(8,12,24,28,32776,32780,32792,32796)) | Measure).Count -GT 0
return $defender
