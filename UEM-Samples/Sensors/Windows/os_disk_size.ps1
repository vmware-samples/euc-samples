# Returns size of the SystemDrive
# Return Type: Integer
# Execution Context: System 
# Execution Architecture: Auto

$drives = get-disk
foreach ($drive in $drives){
    if($drive.IsSystem){

        $systemdriveletter = $pwd.drive.Name
        $drv = Get-Volume | Where-Object {$_.DriveLetter -eq $systemdriveletter}
        $size = [int]($drv.Size /1GB)
        return $size
    }
}