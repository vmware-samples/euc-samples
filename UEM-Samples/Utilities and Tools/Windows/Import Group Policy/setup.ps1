#Test to see if we are in Dev Mode
if($PSScriptRoot -eq ""){
    $InstallPath = "C:\Temp\grppolicies";
}
else{
    #Only works if running from the file
    $InstallPath = $PSScriptRoot;
} 
$InstallFile = $InstallPath + "\Import_Group_Policy.zip";
$SetupFiles = $InstallPath + "\SetupFiles"
$FileVersion = $InstallPath + "\SetupFiles\Import_Group_Policy.version"

#Unzip function
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

#Validate if the product is already installed.  If the file exists exit.
#Will eventually need logic for new versions of the product.
if(Get-Item $FileVersion){
	return;
} 

#Step 1 - Unzip utility
try{
	if(Get-Item $InstallFile){
		#Unzip file
		Unzip $InstallFile $InstallPath -ErrorAction Stop

		Remove-Item $InstallFile
		
		#Unlock files in ZIP
		GetChildInfo $InstallPath | Unlbock-File -WhatIf
	}
} catch {
	echo "Already unziped"
}

#Step 2 - Install Job
cd $SetupFiles
Try{
	Register-ScheduledTask -Xml (Get-Content "Import_Group_Policy.xml" | out-string) -TaskName "Import_Group_Policy" -TaskPath "\AirWatch MDM\" -ErrorAction Stop
} Catch {
	$e = 1
}

#Step 3 - Make directory structure
mkdir "C:\temp\grppolicies\Policies\Cache"
mkdir "C:\temp\grppolicies\Policies\InProgress"
mkdir "C:\temp\grppolicies\Policies\Installed"