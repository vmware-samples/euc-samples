while (-not $completed)
{
	if ((Test-Path "C:\Program Files (x86)\VMware\VMware Horizon View Client\vmware-view.exe") -and ((Get-LocalUser).name -eq "kioskUser0"))
	{
		$completed = $true;
		shutdown /r /t 3
		}
	else
	{
		echo 'Waiting';
		start-sleep 3
	}
}