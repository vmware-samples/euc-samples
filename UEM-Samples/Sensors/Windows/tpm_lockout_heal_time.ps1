# Description: Returns time (string) for how long the TPM will be locked out, if it locks
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$tpm=get-tpm
$status = $tpm.LockoutHealTime
return $status
