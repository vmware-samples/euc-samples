# Description: Returns time (string) for how long the TPM will be locked out, if it locks
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$tpm=get-tpm
$status = $tpm.LockoutHealTime
return $status
