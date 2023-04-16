# Returns True/False if Process is Running or Not. 
# Return Type: Boolean
# Execution Context: User
# change TaskScheduler to your process name
$process = Get-Process TaskScheduler -ea SilentlyContinue
if($process){
	write-output $true
	}else{
	write-output $false
}

