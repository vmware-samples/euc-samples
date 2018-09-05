#Deploy-LGPO
$basePath = $PSScriptRoot
$installPath = "$env:ProgramData\AirWatch\LGPO"

function Extract-LGPO{
    if((Test-Path $installPath) -eq $false){
        md $installPath
    }
    Copy-Item "$basepath\LGPO.exe" -Destination "$installPath" -Force
}

function Main{
    $basePath
    Extract-LGPO
}

Main