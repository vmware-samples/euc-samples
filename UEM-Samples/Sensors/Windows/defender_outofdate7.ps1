# Description: Returns True if Windows Defender signature was last updated less than or equal to 7 day ago and more than 1 day ago.
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$defender=(Get-Date).Subtract((Get-MpComputerStatus).AntispywareSignatureLastUpdated).TotalDays -GT 1 -and (Get-Date).Subtract((Get-MpComputerStatus).AntispywareSignatureLastUpdated).TotalDays -LE 7
return $defender
