#############################################
# File: install_task_psonly.ps1
# Author: Chase Bradley
# Creates task dynamically
#############################################

#Test to see if we are running from the script or if we are running from the ISE
if($PSScriptRoot -eq ""){
    #PSScriptRoot only popuates if the script is being run.  Default to default location if empty
    $current_path = "C:\Installs\AirWatch\setupfiles";
}
else{
    #Only works if running from the file
    $current_path = $PSScriptRoot;
}


cd $current_path
Try{
    #Validate job does not exist
    $registration = Get-ScheduledTask -TaskName "AirWatch_Registration" -ErrorAction Ignore | measure
    if($registration.Count -eq 0){
        $path_root = $current_path.Replace("\setupfiles", "");
        $arg = "-ExecutionPolicy Bypass -File '" + $path_root + "\register_device_ps.ps1'"
        $A = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument $arg 
        $T = New-ScheduledTaskTrigger -AtLogon
        $P = New-ScheduledTaskPrincipal "System" -RunLevel Highest
        $S = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable -Priority 7 -MultipleInstances Parallel
        $D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S 
        Register-ScheduledTask -InputObject $D -TaskName "AirWatch_Registration" -TaskPath "\AirWatch MDM\Enrollment\" -ErrorAction Stop    
    }
	else{
        Write-Host "Error: AirWatch_Registraion job already exists on machine image.  Please Delete then try again."
    }
} Catch {
	$e = 1
    Write-Host "Error: Job creation failed.  Validate user rights."
}