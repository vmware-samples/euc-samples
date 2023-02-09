# Description: Queries Windows SID with MDM Enrollment and matches it against current logged in user.
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$script:SID = ([Security.Principal.WindowsIdentity]::GetCurrent().user).value
If ($SID){} else {
	# "No logged in User to verify SID...exiting."
	Return "No_logged_in_User"
}

#Getting GUID from MDM Enrollment
# "Checking for valid Workspace ONE Enrollment..."
$mdm = $false
$path1 = "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*"
$guid = (Get-Item -Path $path1 -ErrorAction SilentlyContinue).PSChildname
if ($guid -eq $null) {
	return "No_MDM_GUID"
} else {
	$path2 = "HKLM:\SOFTWARE\Microsoft\Enrollments\$guid"
	$upn = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).UPN
	$enrollmentState = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).EnrollmentState
	$providerID = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).ProviderID
	$EnrollmentSID = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).SID

	if ($EnrollmentState -eq "1" -and $upn -and $providerID -eq "AirWatchMDM") {
		$mdm = $true
		[string]$EnrollmentSID = (Get-ChildItem HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$guid | Where-Object { $_.Name -notlike "*device" }).PSChildName
		# Matching current logged in user SID with enrollment SID
		if($SID -eq $EnrollmentSID){
			return "SID_Match"
		} else {
			Return "SID_Mismatch"
		}
	}
}
