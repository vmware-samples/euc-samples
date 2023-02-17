# Description: Searches file system for specified file existence (psexec.exe and psexec64.exe) on C:\ drive
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$psexec = Get-Childitem -Path C:\ -Include psexec.exe,psexec64.exe -Recurse -ErrorAction SilentlyContinue

If ($psexec)
{
$path = $psexec.FullName

for ($i=0; $i -lt $path.length; $i++)
    {
	$list += $path[$i] + ","
    }
Return $list
}

