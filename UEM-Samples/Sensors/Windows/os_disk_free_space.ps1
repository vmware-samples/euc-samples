# Returns free space on System Drive
# Return Type: Integer
# Execution Context: System 
# Execution Architecture: Auto

$drives = get-disk
foreach ($drive in $drives){
    if($drive.IsSystem){

        $systemdriveletter = $pwd.drive.Name
        $drv = Get-Volume | Where-Object {$_.DriveLetter -eq $systemdriveletter}
        $sizeremaining = [int]($drv.SizeRemaining /1GB)
        return $sizeremaining
    }
}