# Returns "Charging" or "Not Charging" if the battery is charging or not
# Return Type: String
# Execution Context: System

# Check for existence of battery
if ((Get-WmiObject -Class Win32_Battery).count -ne 0)
{
	
    $charge_status = (Get-WmiObject -Class Win32_Battery).batterystatus
    $charging = @(2,6,7,8,9)
    if($charging -contains $charge_status[0] -or $charging -contains $charge_status[1] )
    {
	    write-output "Charging"
	    }else{  
	    write-output "Not Charging"
    }

}
else
{
	Write-Output "No battery found"
}
