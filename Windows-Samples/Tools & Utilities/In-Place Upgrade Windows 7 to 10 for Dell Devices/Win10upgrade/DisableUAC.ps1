New-Variable -Name Key
New-Variable -Name PromptOnSecureDesktop_Name
New-Variable -Name ConsentPromptBehaviorAdmin_Name

Function Set-RegistryValue { 
  [cmdletbinding(SupportsShouldProcess=$True,ConfirmImpact="Low")]
  Param ($key, $name, $value, $type="Dword")
  If ((Test-Path -Path $key) -Eq $false) { New-Item -ItemType Directory -Path $key | Out-Null } 
  	If ($pscmdlet.ShouldProcess($value)) {
       Set-ItemProperty -Path $key -Name $name -Value $value -Type $type 
	}
} 

Function Get-RegistryValue($key, $value) { 
   (Get-ItemProperty $key $value).$value 
} 

$Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$ConsentPromptBehaviorAdmin_Name = "ConsentPromptBehaviorAdmin"
$PromptOnSecureDesktop_Name = "PromptOnSecureDesktop"

Function Get-UACLevel(){
	$ConsentPromptBehaviorAdmin_Value = Get-RegistryValue $Key $ConsentPromptBehaviorAdmin_Name
	$PromptOnSecureDesktop_Value = Get-RegistryValue $Key $PromptOnSecureDesktop_Name
	If($ConsentPromptBehaviorAdmin_Value -Eq 0 -And $PromptOnSecureDesktop_Value -Eq 0){
		"Never notIfy"
	}
	ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 5 -And $PromptOnSecureDesktop_Value -Eq 0){
		"NotIfy me only when apps try to make changes to my computer(do not dim my desktop)"
	}
	ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 5 -And $PromptOnSecureDesktop_Value -Eq 1){
		"NotIfy me only when apps try to make changes to my computer(default)"
	}
	ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 2 -And $PromptOnSecureDesktop_Value -Eq 1){
		"Always notIfy"
	}
	Else{
		"Unknown"
	}
}
	
<#
    Powershell run as administrator
    Level   UAC Description                            ConsentPromptBehaviorAdmin    PromptOnSecureDesktop
     0		Never notIfy										 0							 0 
	 1		NotIfy me only(do not dim my desktop)				 5							 0
	 2		NotIfy me only(default)								 5							 1
	 3		Always notIfy										 2							 1
#>
Function Set-UACLevel() {
    [cmdletbinding(SupportsShouldProcess=$True,ConfirmImpact="Low")]
	Param([int]$Level= 2)

	New-Variable -Name PromptOnSecureDesktop_Value
	New-Variable -Name ConsentPromptBehaviorAdmin_Value

	If($Level -In 0, 1, 2, 3) {
		$ConsentPromptBehaviorAdmin_Value = 5
		$PromptOnSecureDesktop_Value = 1
	    Switch ($Level) 
        { 
		  0 {
			  $ConsentPromptBehaviorAdmin_Value = 0 
			  $PromptOnSecureDesktop_Value = 0
		  } 
		  1 {
			  $ConsentPromptBehaviorAdmin_Value = 5 
			  $PromptOnSecureDesktop_Value = 0
		  } 
		  2 {
			  $ConsentPromptBehaviorAdmin_Value = 5 
			  $PromptOnSecureDesktop_Value = 1
		  } 
		  3 {
			  $ConsentPromptBehaviorAdmin_Value = 2 
			  $PromptOnSecureDesktop_Value = 1
		  } 
        }
		If ($pscmdlet.ShouldProcess($Value)) {
			Set-RegistryValue -Key $Key -Name $ConsentPromptBehaviorAdmin_Name -Value $ConsentPromptBehaviorAdmin_Value
			Set-RegistryValue -Key $Key -Name $PromptOnSecureDesktop_Name -Value $PromptOnSecureDesktop_Value
		}

		Get-UACLevel
	}
	Else{
		"No supported level"
	}
	
}

Set-UACLevel 0
