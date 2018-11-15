# Returns "Charging" or "Not Charging" if the battery is charging or not
# Return Type: String
# Execution Context: User
$charge_status = (Get-CimInstance win32_battery).batterystatus
$charging = @(2,6,7,8,9)
if($charging -contains $charge_status[0] -or $charging -contains $charge_status[1] )
{
	echo "Charging"
	}else{  
	echo "Not Charging"
}