
# Queries Windows SID with MDM Enrollment and matches it against current logged in user.
# Return Type: String
# Execution Context: 32bit (forced). Required if you have clients on pre-1910 hub. 
# Author: bpeppin, 2/25/20

$checksid = {

$temp = "HKU"
New-PSDrive $temp Registry HKEY_USERS -ErrorAction SilentlyContinue | out-null
$SID = (get-childitem HKL: -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*S-1-12-1*" -or $_.Name -like "*S-1-5-21*" -And $_.Name -notlike "*_classes" }).Name
Remove-PSDrive $temp
If ($SID)
{
$SID = $SID.Split('\')[1]
return $SID
}else{
return "No_logged_in_User"
}


    $GUID = (Get-Item -Path "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*" -ErrorAction SilentlyContinue).PSChildname
    if ($GUID -eq $null)
    {

	    return "No_MDM_GUID"
    }
    foreach ($row in $GUID)
    {
		
	    $path2 = "HKLM:\SOFTWARE\Microsoft\Enrollments\$row"
	    $upn = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).UPN
	    $enrollmentState = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).EnrollmentState
	    $providerID = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).ProviderID
		
	    if ($providerID -eq "AirWatchMDM")
	    {
		    [string]$EnrollmentSID = (Get-ChildItem HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$row| Where-Object { $_.Name -notlike "*device" }).PSChildName
			
		    If ($SID -eq $EnrollmentSID -and $enrollmentState -eq 1)
		    {
			    return "SID_Match"

		    }
		    else
		    {

			    Return "SID_Mismatch"
		    }
			
	    }
    }
}
$encoded = [convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($checksid))
&"$env:windir\Sysnative\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -EncodedCommand $encoded

# bpeppin, Updated 2/24/20. 
# Queryies Windows SID with MDM Enrollment and matches it against current logged in user.
# Return Type: String
# Execution Context: Auto. Required if all clients on on 1910 hub or later.
# Author: bpeppin, 2/24/20


New-PSDrive HKU Registry HKEY_USERS | out-null
$SID = (get-childitem HKU: | Where-Object { $_.Name -like "*S-1-12-1*" -or $_.Name -like "*S-1-5-21*" -And $_.Name -notlike "*_classes" }).Name
$SID = $SID.Split('\')[1]
Remove-PSDrive HKU


$GUID = (Get-Item -Path "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*" -ErrorAction SilentlyContinue).PSChildname
if ($GUID -eq $null)
{

	return "No_MDM_GUID"
}
foreach ($row in $GUID)
{
	
	$path2 = "HKLM:\SOFTWARE\Microsoft\Enrollments\$row"
	$upn = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).UPN
	$enrollmentState = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).EnrollmentState
	$providerID = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).ProviderID
	
	if ($providerID -eq "AirWatchMDM")
	{
		[string]$EnrollmentSID = (Get-ChildItem HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$row| Where-Object { $_.Name -notlike "*device" }).PSChildName
		
		If ($SID -eq $EnrollmentSID -and $enrollmentState -eq 1)
		{
			return "SID_Match"

		}
		else
		{

			Return "SID_Mismatch"
		}
		
	}
}

