# Returns "Windows 11 Ready" if SystemDrive is equal to or greater than 64GB AND disk space remaining is equal to or greater than 20GB
# Return Type: Integer
# Execution Context: System 
# Execution Architecture: Auto

#variables
$reqsize = 64
$reqsizeremaining = 20

$drives = get-disk
foreach ($drive in $drives){
    if($drive.IsSystem){

        $systemdriveletter = $pwd.drive.Name
        $drv = Get-Volume | Where-Object {$_.DriveLetter -eq $systemdriveletter}
        $sizeremaining = [int]($drv.SizeRemaining /1GB)
        $size = [int]($drv.Size /1GB)

        if($size -ge $reqsize -and $sizeremaining -ge $reqsizeremaining){return "Windows 11 Ready"}else{return "NOT Windows 11 Ready"}
    }
}