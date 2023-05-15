# Description: Generate a randomized strong password and set on the local Administrator account. Change the password length and user using the variables
# Execution Context: System
# Execution Architecture: EITHER64OR32BIT
# Timeout: 30
# Variables: PasswordLength,12; AdminUser,Administrator


Function Invoke-GenerateStrongPassword {
  param (
    [Parameter(Mandatory=$true)]
    [int]$PasswordLength
  )
  Add-Type -AssemblyName System.Web
  $PassComplexCheck = $false
  do {
	$newPassword=[System.Web.Security.Membership]::GeneratePassword($PasswordLength,1)
	  If ( ($newPassword -cmatch "[A-Z\p{Lu}\s]") `
		-and ($newPassword -cmatch "[a-z\p{Ll}\s]") `
		-and ($newPassword -match "[\d]") `
		-and ($newPassword -match "[^\w]")){
		$PassComplexCheck=$True
	  }
  } While ($PassComplexCheck -eq $false)
	$securenewpwd = $newPassword | ConvertTo-SecureString -AsPlainText -Force
	return $securenewpwd
}

Function Invoke-SetPassword {
  Param(
    [Parameter(Mandatory=$True)]
    $securenewpwd,
    [Parameter(Mandatory=$True)]
    [string]$AdminUser
  )
	
  try {
    Set-LocalUser -Name $AdminUser -Password $securenewpwd
  }
  catch {
    write-host "couldn't set password."
	Exit 1
  }
}

$securenewpwd = Invoke-GenerateStrongPassword -PasswordLength $env:PasswordLength
Invoke-SetPassword -securenewpwd $securenewpwd -AdminUser $env:AdminUser
