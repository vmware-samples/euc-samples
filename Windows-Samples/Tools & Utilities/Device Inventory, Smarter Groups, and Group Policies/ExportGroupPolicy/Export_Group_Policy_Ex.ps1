<#
	#Author: Chase Bradley
    #September 2017
    #
	#Licensed under the Apache License, Version 2.0 (the "License");
	#you may not use this file except in compliance with the License.
	#You may obtain a copy of the License at
    #
	#	http://www.apache.org/licenses/LICENSE-2.0
    #
	#Unless required by applicable law or agreed to in writing, software
	#distributed under the License is distributed on an "AS IS" BASIS,
	#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	#See the License for the specific language governing permissions and
	#limitations under the License.*/
#>

[CmdletBinding()]
Param
(
    [switch]$SplitFile=$true,
    #Switch to use the ADMX database to add additional data to the export.  Language is managed by local language pack.
    [switch]$UseAdmxDb=$true,
    [Parameter(Mandatory=$false)]
    [ValidateSet("Admx","PolicyPath","PolicyFile","PolicyOrigin","RegPath")]
    [string]$GroupBy="PolicyPath",
    [switch]$AddMetadata=$true
)

#
$current_path = $PSScriptRoot;
if($PSScriptRoot -eq ""){
    $current_path = "C:\Temp\GroupPolicy\Export";
    $shared_path = "C:\Temp\shared";
}

#Import the ADMX Database (en-US) into memory for metadata use
If($UseAdmxDb){
    $DatabaseFile = "\admx (en-US).db";
    $CurrentLanguagePack = (Get-Culture).Name;
    if(Test-Path ($LocalPath + "\admx ($CurrentLanguagePack).db")){
        $DatabaseFile = "\admx ($CurrentLanguagePack).db"
    }
    $AdmxLines = [IO.File]::ReadAllText($current_path + $DatabaseFile);
    $AdmxDb = ConvertFrom-Json $AdmxLines; 
} else{
    $AdmxDb = New-Object -TypeName PSCustomObject -Property @{"Entries"=@()};
}

#Function to get 
function Get-ADMXLookup{
    [CmdletBinding()]
    param(
        [object]$Entry
     )
    $Results = "";
    if($Entry.ValueName.Contains("**DeleteKeys")){
        $EntryValidationStr = $Entry.KeyName;
    } ElseIf ($entry.ValueName.Contains("**delvals.")){
        $EntryValidationStr = $Entry.KeyName;
    } Else{
        $EntryValidationStr = ($Entry.KeyName + "!" + $Entry.ValueName).Replace("**del.","");
    }
    $EntryValidationStr = $EntryValidationStr.Replace("\","\\");
    $EntryTest = $AdmxDb.Entries.Where({$_.RegistryEntries -match $EntryValidationStr})
    if(($EntryTest | measure).Count -gt 0){
        $Results = $EntryTest[0];
    }
    return $Results;
}

function Get-RegKeyLookup{
    [CmdletBinding()]
    param(
        [object]$Entry
    )
    $PathGroup = "";
    if($entry.KeyName -match "Software\\Policies\\(?:Microsoft|([^\\]*))\\(?:Windows|([^\\]*))(?:$|\\([^\\]*))(?:$|\\([^\\]*))"){
        if($Matches[2]){
            if($Matches[1]){
                $PathGroup = $Matches[1] + "_" + $Matches[2];
            } Else{
                $PathGroup = $Matches[2];
            }
        } elseif($Matches[4] -and $Matches[3]){
            $PathGroup = $Matches[3] + "_" + $Matches[4];
        } elseif($Matches[3]){
            $PathGroup = $Matches[3];
        } 
    } 
    return $PathGroup;
}

function Migrate-Policies{
    [CmdletBinding()]
	param(
          #Used to set the local path for the method
          [string]$LocalPath,
          #Switch to split the files into logical groups
          [switch]$SplitFile=$false,
          #Switch to use the (EN-en) ADMX database to add additional data to the export
          [switch]$UseAdmxDb=$false,
          [Parameter(Mandatory=$false)]
          [ValidateSet("Admx","PolicyPath","PolicyFile","PolicyOrigin")]
          [string]$GroupBy="PolicyPath",
          [switch]$AddMetadata=$false
        )
    if(!$LocalPath){
        $LocalPath = "C:\Temp\GroupPolicy\ExportTool";
    }
    $current_path = $LocalPath;

    #Configure new export directory
    $timestamp = Get-Date -format yyyyMMdd;
    $ExportPathCount = (Get-ChildItem -Path $current_path -Force -Filter "export$timestamp*" | measure).Count; 
    $ExportFullPath = $current_path + "\export$timestamp" + "_" + $ExportPathCount;
    $ExportPath = "export$timestamp" + "_" + $ExportPathCount;
    New-Item -Path $current_path -Name $ExportPath -ItemType Directory;
    #Used for single file export
    $ExportFile = "export_gpo.csv";
	
    #Change directory to running directory
	cd $LocalPath
    $shared_path = "C:\Temp\Shared";
    #Import the 
    Try{
        #Initialize common utilities       
        If(Test-Path ($shared_path + "\Utility-Functions.psm1")){
            Unblock-File ($shared_path + "\Utility-Functions.psm1")
            $utilitys = Import-Module ($shared_path + "\Utility-Functions.psm1")  -ErrorAction Stop -PassThru -Force    
        }
    }
    Catch{
        $exception = $_.Exception.Message;
    }    
	
    Unblock-File "..\LGPO.exe";
    #$ExportArgs = '/b "' + "$ExportFullPath" + '"';
    #$LGPO = Start-Process -FilePath "..\LGPO.exe" -ArgumentList $ExportArgs;
    
   
    $PolPaths = @{};
    $SystemPolPaths = Get-ChildItem -Path "$env:systemroot\System32\GroupPolicy\"  -Recurse -Force -Filter "registry.pol"
    $UserCount = 0;
    $MachineCount = 0;
    foreach($SystemPolFile in $SystemPolPaths){
        $ContextPath = $SystemPolFile.Directory.Name;
        if($ContextPath -eq "User"){
            $PolPaths.Add("User$UserCount", $SystemPolFile.FullName);
            $UserCount++;
        } elseif ($ContextPath -eq "Machine"){
            $PolPaths.Add("Machine$MachineCount", $SystemPolFile.FullName);
            $MachineCount++;
        }
    }

    $UserRegPaths = Get-ChildItem "$env:systemroot\System32\GroupPolicyUsers\" -Recurse -Force -Filter "*.pol";
    foreach($UserPolFile in $UserRegPaths){
        $UserSID = $UserPolFile.DirectoryName;
        $UserSID = $UserSID.Replace("$env:systemroot\System32\GroupPolicyUsers\","").Replace("\User","");
        $UserName = Get-ReverseSID $UserSID;
        if(!($UserName.Contains("Error"))){
            $PolPaths.Add($UserName, $UserPolFile.FullName);
        }
    }

    
    
    $s = @{};
    foreach($i in $PolPaths.Keys){
        if(Test-Path $PolPaths[$i]){
            $PolicyFile = $PolPaths[$i];
            $ArgumentList = "/parse /m $PolicyFile"
            $Export = Start-Process -FilePath "..\LGPO.exe" -ArgumentList $ArgumentList -RedirectStandardOutput "$ExportFullPath\$i.txt" -NoNewWindow -Wait

            $ExportFileAgg = Get-Content -Path "$ExportFullPath\$i.txt" -Force;
            Add-Content -Path "$ExportFullPath\export_gpo.txt" -Value $ExportFileAgg;
        }
	}
}

Migrate-Policies -LocalPath $current_path