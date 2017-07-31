<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.3.131
	 Created on:   	1/25/2017 11:13 AM
	 Modified on:	7/28/2017 9:04 AM
	 Created by:   	jhandy@vmware.com 
	 Contributor:	jnegron@vmware.com	
	===========================================================================
	.DESCRIPTION
		Performs upgrade to Windows 10 Enterprise 64-bit, MBR2GPT, BIOs to UEFI conversion, and installs AirWatch Agent and enrolls. Please update file paths. 
#>


### Confirm if the installation  folder exists
$installfile = "C:\DeplymentShare\Win10upgrade\Install.cmd"
if (Test-Path $installfile)
	{
	
	### Confirming and upgrading to Windows 10 Enterprise 64-bit if applicable
	$computer = "."
	$winversion = Get-WMIObject Win32_OperatingSystem -ComputerName $computer | select-object Description, Caption, OSArchitecture, ServicePackMajorVersion
	
	If ($winversion -match "64-bit")
	{
		If ($winversion -notmatch "Windows 10")
		{
			& "C:\DeplymentShare\Win10upgrade\Install.cmd"
		}
		### Confirming Parition Style, and bois type
		
    	$partitionstyle = gwmi -query "Select * from Win32_DiskPartition WHERE Index = 0" | Select-Object DiskIndex, @{ Name = "GPT"; Expression = { $_.Type.StartsWith("GPT") } }
	    $GPT = ($partitionstyle |select -ExpandProperty GPT)
	    $GPTtrue = $GPT | where {$_ -match "True"}
        $OSBuild = [System.Environment]::OSVersion.Version
		
		If ($GPTtrue -eq $null)
		{
			
			cd c:\DeplymentShare\Win10upgrade\MBRGPT
					
			& "C:\DeplymentShare\Win10upgrade\MBR2GPT.cmd"
			& "C:\DeplymentShare\Win10upgrade\boistouefi.cmd"
			& "C:\DeplymentShare\Win10upgrade\DisableUAC.ps1"
			
			
			
			Restart-Computer -Force
			
		}
		
		$DriveLetter = (Get-Volume -FileSystemLabel "SYSTEM RESERVED").DriveLetter
		
		IF ($DriveLetter -ne $null)
		{
			$AccPath = ($DriveLetter + ":")
			$PartNo = (Get-Partition -DriveLetter $DriveLetter).PartitionNumber
			$DiskNo = (Get-Partition -DriveLetter $DriveLetter).DiskNumber
			Remove-PartitionAccessPath -DiskNumber $DiskNo -PartitionNumber $PartNo -AccessPath $AccPath
		}
		
		$AirWatchInstalled = Test-Path "C:\Program Files (x86)\AirWatch\AgentUI\ar"
		
		IF ($AirWatchInstalled -eq $false)
		{
			
			Start-Job -Name Job3 -ScriptBlock { & "C:\DeplymentShare\Win10upgrade\AirwatchAgent.cmd" }
			Wait-Job -Name Job3
			
			Start-Sleep -s 15
			
			Start-Job -Name Job4 -ScriptBlock { & "C:\DeplymentShare\Win10upgrade\AirwatchAgentuninstall.cmd" }
			Wait-Job -Name Job4
			
			Start-Sleep -s 45

			C:\DeplymentShare\Win10upgrade\AirwatchAgent.cmd -en ASCII
		}
	}
	
	
	
}




