#Test to see if we are in Dev Mode
if($PSScriptRoot -eq ""){
    $current_path = "C:\Installs\AirWatch\setupfiles\";
}
else{
    #Only works if running from the file
    $current_path = $PSScriptRoot;
} 

$url = "https://awagent.com/Home/DownloadWinPcAgentApplication"
$output = "$current_path\AirWatchAgent.msi"
$start_time = Get-Date

Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $output

Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"