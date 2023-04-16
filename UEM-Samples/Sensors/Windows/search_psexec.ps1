# Searches file system for existence of psexec.exe and psexec64.exe on C drive (ensure you test to ensure it runs and completes in a timely matter!)
# Return Type: String
# Execution Context: System
# Author: bpeppin

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


# Searches file system for existence of psexec.exe and psexec64.exe on in users folder only (less impact on disk)
# Return Type: String
# Execution Context: User
# Author: bpeppin

$psexec = Get-Childitem -Path C:\Users -Include psexec.exe,psexec64.exe -Recurse -ErrorAction SilentlyContinue

If ($psexec)
{
$path = $psexec.FullName

for ($i=0; $i -lt $path.length; $i++)
    {
	$list += $path[$i] + ","
    }
Return $list
}
