# Description: Returns True if Windows Defender signature was last updated less than or equal to 1 day ago. You want this to be True!
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$defender=(Get-Date).Subtract((Get-MpComputerStatus).AntispywareSignatureLastUpdated).TotalDays -LE 1
return $defender
