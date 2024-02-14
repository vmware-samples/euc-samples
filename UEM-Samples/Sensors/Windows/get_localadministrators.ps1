# Description: Return the current member of local administrators group.
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$localadminmember = $(net localgroup administrators) | Where-Object { -not ($_ -match '^-+$|^The command completed successfully.$|^Members$|^Alias name\s+administrators$|^Comment\s+Administrators have complete and unrestricted access to the computer/domain$|^$') -and $_.Trim() -ne '' }
$memberlist = ($localadminmember -join ";")
write-output $memberlist
