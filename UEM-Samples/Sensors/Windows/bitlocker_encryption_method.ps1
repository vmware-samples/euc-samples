# Returns Encryption Method for a BitLocker drive
# Only returns information for C:
# Return Type: String
# Execution Context: System
$EncryptionMethod = (Get-BitLockerVolume -MountPoint C:).EncryptionMethod
write-output $EncryptionMethod