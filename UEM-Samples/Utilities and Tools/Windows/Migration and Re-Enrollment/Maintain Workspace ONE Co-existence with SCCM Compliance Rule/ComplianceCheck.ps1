#Compliance Script. For use in SCCM Compliance item as a discovery script.
#Checking first for Airwatch Enrollment
$val = (Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*" -ErrorAction SilentlyContinue).PSChildname

#Now checking whether enrollment is with a real user or the staging user
$path2 = "HKLM:\SOFTWARE\Microsoft\Enrollments\$val"
$val2 = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).UPN

#This will be "Completed" if it is staged enrollment has completed but not yet flipped to final user
$staging = (get-itemproperty -path HKLM:\SOFTWARE\AIRWATCH\EnrollmentStatus -ErrorAction SilentlyContinue).status
$reassignment = (get-itemproperty -path HKLM:\SOFTWARE\AIRWATCH\Reassignment -ErrorAction SilentlyContinue).status


if ($staging -eq "Completed" -and $reassignment -eq $null)
{
	Write-Host "Non-Compliant"
}
Elseif ($val2 -like "*staging*" -or $val2 -eq $null)
{
	Write-Host "Non-Compliant"
}else
{
    write-host "Compliant"

}
