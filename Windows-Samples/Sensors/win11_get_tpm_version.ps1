# Get TPM Version available on device:
#   Windows 11 Ready = 2.0
#   Windows 11 OK = 1.2
#   Not Windows 11 Ready = other
# Return Type: String
# Execution Context: System 
# Execution Architecture: Auto

$tpm = Get-WmiObject -Namespace $NameSpace -Query "Select * from win32_tpm"
if($tpm.SpecVersion.Contains("2.0")){
    return "Windows 11 Ready"}
else{
    if($tpm.SpecVersion.Contains("1.2")){
        return "Windows 11 OK"}
    else{
        return "NOT Windows 11 Ready"
    }
}