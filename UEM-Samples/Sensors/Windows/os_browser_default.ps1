# Description: Returns the users default web browser.
# Execution Context: USER
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$browser = Get-ItemProperty HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice | Select-Object -ExpandProperty ProgId
Switch -regex ($browser) { 
<#
	Note that the strings in '' may need changed. This was tested on Windows 10 with latest versions of Chrome and Firefox.
#>
    "ChromeHTML" { Write-Output "Google Chrome" }
    "OperaStable" { Write-Output "Opera Stable" }
    "IE.HTTP" { Write-Output "Internet Explorer" }
    "\bFirefoxURL\b" { Write-Output "Mozilla FireFox" }
    "AppXq0fevzme2pys62n3e0fbqa7peapykr8v" { Write-Output "Microsoft Edge" }
    default {Return $browser}
}

