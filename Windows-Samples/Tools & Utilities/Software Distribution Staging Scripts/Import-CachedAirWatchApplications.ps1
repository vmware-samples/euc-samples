#Requires -RunasAdministrator
<# Migrate SCCMApps-AirWatch Powershell Script Help
  .SYNOPSIS
    This Powershell script allows you to prestage Applications in the Software Distribution Folder
    MUST RUN AS ADMIN
  .DESCRIPTION
    When run, this script will prompt you to select all applications for staging or show a UI for selecting targeted applications.
  .EXAMPLE
    .\Import-CachedAirWatchApplications.ps1 `
        -$SourcePath "C:\Temp" `
        -All `
        -Verbose
  .PARAMETER $SourcePath
    The Site Code of the SCCM Server that the script can set the location to.
  .PARAMETE $All
    Commandline flag to import all the apps from the source directory to the App Deployment Cache.
#>
[CmdletBinding()]
    Param(
        [parameter(Mandatory=$true)] $SourcePath,
        [switch]$All
    )


Function Show-AppSelectionUI {
    param($SourcePath)

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $SourcePath
    $OpenFileDialog.Multiselect = $True
    $OpenFileDialog.ShowDialog() | Out-Null
    
    Return $OpenFileDialog.FileNames
}

Function Import-AppsToCache {

   param(
       $Apps,
       $Path
   )

   $destinationPath = "C:\ProgramData\AirWatchMDM\AppDeploymentCache"
   
   if($Apps.Count -eq 0) {
     Write-Host "No Apps to Import in the Source path...exiting"
     EXIT
   }

   Write-Host "Beginning Import Process"
   if(-not $(Test-Path -Path $destinationPath)) {
        Write-Host "AppDeploymentCache doesn't exist...creating directory now"
        New-Item -Path C:\ProgramData\AirWatchMDM -Name "AppDeploymentCache" -ItemType "directory"
   }
   
   Write-Host "Decompressing Exported Apps"

   foreach($App in $Apps) {
       try {
           Write-Host "Extracting $($App.FullName)"
           Expand-Archive -Path $App.FullName -DestinationPath $destinationPath
       } catch {
           Write-Host "Unable to unzip $($App.Name)" -ForegroundColor Red
       }
   }

   Write-Host "Import Complete" -ForegroundColor Yellow
}

Function Main {
    [CmdletBinding()]
    param(
        $SourcePath
    )

    if($All) {
        Write-Host "All Apps located at $($SourcePath) will be imported"
        $Apps = Get-ChildItem -Path $SourcePath
    } else {
        Write-Host "Showing UI for Apps to be imported"
        $Apps = Show-AppSelectionUI -SourcePath $SourcePath | foreach { Get-ChildItem -Path $_}
    }

    Write-Host "Importing $($Apps.Count) Apps"
    Import-AppsToCache -Apps $Apps -Path $SourcePath

    
}

Main -SourcePath $SourcePath