# Description: Returns the value of the Windows Product Key
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$key=((Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey).trim()
Return $key