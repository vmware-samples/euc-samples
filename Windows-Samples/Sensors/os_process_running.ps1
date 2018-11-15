# Returns True/False if Process is Running or Not. 
# Return Type: Boolean
# Execution Context: User
# change mcshield to your process name
$process = Get-Process mcshield -ea SilentlyContinue
if($process){
	write-output $true
	}else{
	write-output $false
}

