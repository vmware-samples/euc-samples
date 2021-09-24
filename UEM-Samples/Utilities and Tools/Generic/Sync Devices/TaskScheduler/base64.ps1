Function Get-Base64Encode {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$UserPass 
        )
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($UserPass)
    $script:cred =[Convert]::ToBase64String($Bytes)
    return $script:cred   
}

if ([string]::IsNullOrEmpty($Username))
{
    $Username = Read-Host -Prompt 'Enter the account to access Workspace ONE UEM API'       
}
if ([string]::IsNullOrEmpty($Password))
{
    $Password = Read-Host -Prompt 'Enter the password to access Workspace ONE UEM API'    
}

$combined = $Username + ":" + $Password
Get-Base64Encode -UserPass $combined
Write-Host Paste the value on the third line of config.ini. Value: $cred