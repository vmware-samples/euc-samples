# Description: Sensor to find certificates in the current user store that match a given subject search string and check if they are revoked.
# Remember to set the subject search string in the $subjectPattern variable.  This will search the subject for any instance of the string.
# If you are testing this on a windows machine, you can change the $testing variable to $true and it will log to a file in the temp directory and show it at the end.
# Execution Context: USER
# Execution Architecture: 64-bit
# Return Type: STRING

# Variables
$subjectPattern = "*testsearchstring*" # Replace with your subject search string

# When testing, set the following variable to true to log to a temp directory and then open the file at the end to see the results
$testing = $false

# Helper function for formatted date/time
function Get-FormattedDateTime {
    return (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

if ($testing) {
    $testLogFile = Join-Path $env:TEMP "testCertRevocation.txt"
    Set-Content -Path $testLogFile -Value "$(Get-FormattedDateTime): Start of Test Log`n"
}


# Check in TEMP if the Bouncycastle dll is available
$bouncyCastleDllPath = Join-Path $env:TEMP "BouncyCastle.Crypto.dll"


if (-not (Test-Path $bouncyCastleDllPath)) {
    # Define the URL and the download path
    $url = "https://globalcdn.nuget.org/packages/bouncycastle.cryptography.2.1.1.nupkg"
    $downloadPath = Join-Path $env:TEMP "bouncycastle.cryptography.2.1.1.nupkg"



    # Download the .nupkg file
    Invoke-WebRequest -Uri $url -OutFile $downloadPath

    # Rename the .nupkg to .zip
    $zipPath = $downloadPath -replace '\.nupkg$', '.zip'
    Rename-Item -Path $downloadPath -NewName $zipPath

    # Extract the .zip contents
    $extractPath = Join-Path $env:TEMP "bouncycastle_extracted"
    New-Item -Path $extractPath -ItemType Directory -Force | Out-Null
    Expand-Archive -Path $zipPath -DestinationPath $extractPath

    # Copy the BouncyCastle.Crypto.dll to the current directory
    # Note: The exact location inside the extracted folder may vary. Here we assume it's in the netstandard2.0 folder.
    # Adjust as necessary if the structure of the package changes.
    $sourceDllPath = Join-Path $extractPath "lib\netstandard2.0\BouncyCastle.Cryptography.dll"

    Copy-Item -Path $sourceDllPath -Destination $bouncyCastleDllPath

    # Clean up the extracted folder and the zip file if desired
    Remove-Item -Path $extractPath -Recurse -Force
    Remove-Item -Path $zipPath -Force

    # Now you can load the DLL into your PowerShell session if needed:
    # Add-Type -Path $bouncyCastleDllPath
}

# Load the BouncyCastle dll
Add-Type -Path $bouncyCastleDllPath

# Fetch all matching certificates from the CurrentUser's Personal store
$matchingCertificates = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -like $subjectPattern }

foreach ($cert in $matchingCertificates) {
    if ($testing) {
        $message = "$(Get-FormattedDateTime): Checking certificate: $($cert.Subject)"
        Add-Content -Path $testLogFile -Value $message
    }


    if ($testing) {
        $message = "$(Get-FormattedDateTime): Serial Number: $($cert.SerialNumber)"
        Add-Content -Path $testLogFile -Value $message
    }

    # Split the serial number into chunks of 2 characters
    $hexChunks = $cert.SerialNumber -split '(..)' | Where-Object { $_ }

    # Display and process each chunk
    $serialByteArray = @()
    foreach ($chunk in $hexChunks) {
        #Write-Host "Processing chunk: $chunk"
        $serialByteArray += [byte]::Parse($chunk, [System.Globalization.NumberStyles]::HexNumber)
    }


    # Fetch all CRL distribution points from the certificate
    $crlDistributionPointExtension = $cert.Extensions | Where-Object { $_.Oid.FriendlyName -eq "CRL Distribution Points" }
    #$crlUrlsArray = ($crlDistributionPointExtension.Format(0) -split("`r`n", [StringSplitOptions]::RemoveEmptyEntries) | Where-Object { $_ -like "*URL=*" }) -replace "URL="

    # Extract URLs using regex
    $crlUrlsArray = [System.Text.RegularExpressions.Regex]::Matches($crlDistributionPointExtension.Format(0), 'http://[^\s]*') | ForEach-Object { $_.Value }


    # Initialize variables
    $isRevoked = $false
    $revokedCertificates = @()

    foreach ($crlUrl in $crlUrlsArray) {
        try {
            $webclient = New-Object System.Net.WebClient
            $crlPath = Join-Path $env:TEMP "save.crl"
            $webclient.DownloadFile($crlUrl, $crlPath)

            $crlBytes = [System.IO.File]::ReadAllBytes($crlPath)

            $crlStream = New-Object System.IO.MemoryStream -ArgumentList @(,$crlBytes) # Create a MemoryStream
            $crlParser = [Org.BouncyCastle.X509.X509CrlParser]::new()
            $crl = $crlParser.ReadCrl($crlStream)

             if ($testing) {
                $message = "$(Get-FormattedDateTime): Checking certificate: $($cert.SerialNumber)"
                Add-Content -Path $testLogFile -Value $message
            }

            # Split the serial number into chunks of 2 characters
            $hexChunks = $cert.SerialNumber -split '(..)' | Where-Object { $_ }

            # Display and process each chunk
            $serialByteArray = @()
            foreach ($chunk in $hexChunks) {
                $serialByteArray += [byte]::Parse($chunk, [System.Globalization.NumberStyles]::HexNumber)
            }


            # Convert the byte array to BigInteger
            $serialNumber = New-Object Org.BouncyCastle.Math.BigInteger(1, $serialByteArray)
            $isRevoked = $crl.GetRevokedCertificate($serialNumber) -ne $null

            # Cleanup for this iteration
            Remove-Item -Path $crlPath -Force

        } catch {
            # This handles any errors in downloading or processing a particular CRL. It continues with the next CRL.
            Write-Warning "Error processing CRL from URL ${crlUrl}: $_"
        }
    }



    # If revoked add to array
    if ($isRevoked) {
        $revokedCertificates += $cert.SerialNumber
    }
}

 # If revoked add to array
if ($revokedCertificates.Count -gt 0) {
    $revokedCertsString = "Revoked Certs with subject $($subjectPattern): " + ($revokedCertificates -join ", ")
    Write-Output $revokedCertsString
    if ($testing) {
        $message = "$(Get-FormattedDateTime): $($revokedCertsString)"
        Add-Content -Path $testLogFile -Value $message
    }

} else {
    $message = "No certificates were revoked for searchString $($subjectPattern)."
    Write-Output $message
     if ($testing) {
        $message = "$(Get-FormattedDateTime): $($message)"
        Add-Content -Path $testLogFile -Value $message
    }
}

if ($testing) {
    Invoke-Item $testLogFile
}

