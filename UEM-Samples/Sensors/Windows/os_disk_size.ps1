# Description: Returns size of the System Drive (in GB)
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$drives = get-disk
foreach ($drive in $drives){
    if($drive.IsSystem){

        $systemdriveletter = $pwd.drive.Name
        $drv = Get-Volume | Where-Object {$_.DriveLetter -eq $systemdriveletter}
        $size = [int]($drv.Size /1GB)
        return "$size GB"
    }
}

