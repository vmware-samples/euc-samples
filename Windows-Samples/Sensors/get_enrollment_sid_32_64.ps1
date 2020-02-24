# bpeppin, Updated 2/24/20. 
# Querying which Windows SID has MDM Enrollment
# Return Type: String
# Execution Context: 32bit (forced) if you have clients on pre-1910 hub. 
# Author: bpeppin, 2/24/20

@'
$GUID = (Get-Item -Path "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*" -ErrorAction SilentlyContinue).PSChildname
if ($GUID -eq $null)
{
	return "No_MDM_GUID"
}
	
	$path2 = "HKLM:\SOFTWARE\Microsoft\Enrollments\$guid"
	$upn = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).UPN
	$enrollmentState = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).EnrollmentState
	$providerID = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).ProviderID

	if ($providerID -eq "AirWatchMDM" -and $enrollmentState -eq 1)
	{
		[string]$EnrollmentSID = (Get-ChildItem HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$guid | Where-Object { $_.Name -notlike "*device" }).PSChildName
		
		If ($EnrollmentSID)
		{
			return $EnrollmentSID
		}
		else
		{
			Return "No_Enrollment_SID_Found"
		}
	}
	else
	{
		return "No_MDM_Enrollment"
	}
 
'@ | &"$env:windir\Sysnative\WindowsPowerShell\v1.0\powershell.exe" -Command -

# bpeppin, Updated 2/24/20. 
# Querying which Windows SID has MDM Enrollment
# Return Type: String
# Execution Context: Auto (this requires 1910 agent or newer since it needs 64bit powershell) 
# Author: bpeppin, 2/24/20

$GUID = (Get-Item -Path "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*" -ErrorAction SilentlyContinue).PSChildname
if ($GUID -eq $null)
{
	return "No_MDM_GUID"
}
	
$path2 = "HKLM:\SOFTWARE\Microsoft\Enrollments\$guid"
$upn = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).UPN
$enrollmentState = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).EnrollmentState
$providerID = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).ProviderID

if ($providerID -eq "AirWatchMDM" -and $enrollmentState -eq 1)
{
	[string]$EnrollmentSID = (Get-ChildItem HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$guid | Where-Object { $_.Name -notlike "*device" }).PSChildName
	
	If ($EnrollmentSID)
	{
		return $EnrollmentSID
	}
	else
	{
		Return "No_Enrollment_SID_Found"
	}
}
else
{
	return "No_MDM_Enrollment"
}
