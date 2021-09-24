# Return highest TPM Version the device supports
# Return Type: Integer
# Execution Context: System 
# Execution Architecture: Auto

$NameSpace= "root\cimv2\security\microsofttpm"
$tpm = Get-WmiObject -Namespace $NameSpace -Query "Select * from win32_tpm"
if ($tpm){
  $versions = $tpm.SpecVersion
  [array]$splittpmversions = ($versions -split ', ') -ne ''
  [array]$tpmversionsarray = foreach($number in $splittpmversions) {
    try {
        [int]::parse($number)
    }
    catch {
        Invoke-Expression -Command $number;
    }
  }
  $highesttpmversion = ($tpmversionsarray| Measure-Object -Maximum).Maximum
  if ($highesttpmversion){return $highesttpmversion}  
}else{return 0}
