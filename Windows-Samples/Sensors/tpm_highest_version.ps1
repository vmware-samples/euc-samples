# Return highest TPM Version the device supports
# Return Type: Integer
# Execution Context: System 
# Execution Architecture: Auto

$NameSpace= "root\cimv2\security\microsofttpm"
$tpm = Get-WmiObject -Namespace $NameSpace -Query "Select * from win32_tpm"
$versions = $tpm.SpecVersion
[array]$splittpmversions = ($versions -split ', ') -ne ''
[array]$highesttpmversion = foreach($number in $splittpmversions) {
  try {
      [int]::parse($number)
  }
  catch {
      Invoke-Expression -Command $number;
  }
}
return ($highesttpmversion | Measure-Object -Maximum).Maximum