#Requires -RunasAdministrator

Function Get-DestinationFolder {
    Param(
        [string]$Description="Select Export Destination Folder",
        [string]$BaseDirectory="Desktop"
    )
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $FolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderDialog.RootFolder = $BaseDirectory
    $FolderDialog.Description = $Description
    $FolderDialog.ShowDialog() | Out-Null
    $FolderDialog.SelectedPath
}

Function Export-CachedAirWatchApplications {
    
    $DestinationPath = Get-DestinationFolder
    $SourcePath = 'C:\ProgramData\AirWatchMDM\AppDeploymentCache'

    if($(Test-Path $DestinationPath)) {
        
        Write-Host "Showing dialog to get Deployed Cache"
        $CachedApps = Get-ChildItem -Path $SourcePath

        Foreach($App in $CachedApps) {
            try {
                Write-Host "Compressing $($App.BaseName)"
                Compress-Archive -Path $App.FullName -DestinationPath $DestinationPath\$($App.BaseName).zip
            } catch {
                Write-Host "Unable to compress $($App.Name)"
            }
        }   
    } 
}

#Main
Export-CachedAirWatchApplications