# Description: Returns the Windows SID for the current logged in user. 
# Execution Context: USER
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$SID = ([Security.Principal.WindowsIdentity]::GetCurrent().user).value
If ($SID)
{Return $SID}
else
{return "No_logged_in_User"}

