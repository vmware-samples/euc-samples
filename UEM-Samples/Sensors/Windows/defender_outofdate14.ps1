# Description: Returns True if Windows Defender signature was last updated less than or equal to 14 day ago and more than 7 day ago. 
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$defender=(Get-Date).Subtract((Get-MpComputerStatus).AntispywareSignatureLastUpdated).TotalDays -GT 7 -and (Get-Date).Subtract((Get-MpComputerStatus).AntispywareSignatureLastUpdated).TotalDays -LE 14
return $defender
