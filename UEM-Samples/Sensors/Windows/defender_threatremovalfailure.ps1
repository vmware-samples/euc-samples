# Description: Returns True if any threat is detected and the status is either "CleanFailed", "QuarantineFailed", "RemoveFailed", "AllowFailed", "Abondoned", or "BlockedFailed"
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$defender=(Get-MpThreatDetection | Where-Object {($_.ThreatStatusId -GT 6)} | Measure).Count -GT 0
return $defender
