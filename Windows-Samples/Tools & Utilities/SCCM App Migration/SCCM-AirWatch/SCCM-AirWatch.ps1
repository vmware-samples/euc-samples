<#
  This method extracts specific properties from the SCCM deployment details and stores them in an AirWatch Properties table.
  Different deployment modes require different properties to be stored.
#>
Function Extract-PackageProperties {

    Param(
		[Parameter(Mandatory=$True)]
		[xml]$SDMPackageXML
	)

    [hashtable]$AirWatchProperties = @{}

    # Extract top level app properties
    $ApplicationName = $SDMPackageXML.AppMgmtDigest.Application.Title.InnerText
    $AirWatchProperties.Add("ApplicationName", $ApplicationName)
    $AirWatchProperties.Add("Description", $SDMPackageXML.AppMgmtDigest.Application.Description.InnerText)
    $AirWatchProperties.Add("Developer", $SDMPackageXML.AppMgmtDigest.Application.Publisher.InnerText)
    $AirWatchProperties.Add("ActualFileVersion", $SDMPackageXML.AppMgmtDigest.Application.SoftwareVersion.InnerText)

    # Get the first deployment method of multiple.
    $currentDeployment = $SDMPackageXML.AppMgmtDigest.DeploymentType | Select-Object -First 1

    # Map Install actions section to the corresponding AW properties
    $AirWatchProperties.Add("InstallCommand", ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "InstallCommandLine"}).InnerText)
    $AirWatchProperties.Add("InstallerRebootExitCode", ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "RebootExitCodes"}).InnerText)
    $AirWatchProperties.Add("InstallerSuccessExitCode", ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "SuccessExitCodes"}).InnerText)
    $AirWatchProperties.Add("DeviceRestart", ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "RequiresReboot"}).InnerText)
    $AirWatchProperties.Add("InstallTimeoutInMinutes", ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "ExecuteTime"}).InnerText)

    # Only set Uninstall command if present
    if(($currentDeployment.Installer.UninstallAction.Args.Arg | ? {$_.Name -eq "InstallCommandLine"}).InnerText -eq $null) 
    {
        $AirWatchProperties.Add("UninstallCommandLine","An Uninstall Command is not setup in SCCM. Please update this field")
    } 
    else 
    {
        $AirWatchProperties.Add("UninstallCommandLine", ($currentDeployment.Installer.UninstallAction.Args.Arg | ? {$_.Name -eq "InstallCommandLine"}).InnerText)
    }


    #Set Default Install Context and modify if the Package context is System
    $AirWatchProperties.Add("InstallContext", "User")
        If(($SDMPackageXML.AppMgmtDigest.DeploymentType.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "ExecutionContext"}).InnerText -eq "System")
    {
        $AirWatchProperties.Set_Item("InstallContext", "Device")
    }
    
    # Switch the file generation based on Deployment Technology. Script deployment files are zipped up into a single file.
    switch ($currentDeployment.Technology)
    {
        "MSI"    
                {
                    $source = $currentDeployment.Installer.Contents.Content.Location
                    $file = ($currentDeployment.Installer.Contents.Content.File | ? {$_.Name -like "*.msi"}).Name
                    $uploadFilePath = $source + $file
                    $AirWatchProperties.Add("FilePath", $uploadFilePath)
                }
        "Script" 
                {
                    #Zip Script deployments into a file for upload
                    $source = $currentDeployment.Installer.Contents.Content.Location
                    $parentFolder = ($source | Split-Path -Parent)
                    $folderName = ($source | Split-Path -Leaf)
                    $uploadFilePath = $parentFolder + "\$folderName.zip"
                    #remove zip if already exists
                    If(Test-path $uploadFilePath) {Remove-item $uploadFilePath}
                    Add-Type -assembly "system.io.compression.filesystem"
                    
                    try {
                        [io.compression.zipfile]::CreateFromDirectory($source, $uploadFilePath)
                    } catch {
                        "Unable to zip script file with error: $_"
                    }
                    $AirWatchProperties.Add("FilePath", $uploadFilePath)
                }
    }

    # Get the application identifier from the Enhanced Detection Method

    if(($currentDeployment.Installer.DetectAction.Args.Arg | ? {$_.Name -eq "MethodBody"}).InnerText -eq $null)
    {
        $AirWatchProperties.Add("InstallApplicationIdentifier", "No Product Code Found")        
    }
    else 
    {
        [xml] $enhancedDetectionMethodXML = ($currentDeployment.Installer.DetectAction.Args.Arg | ? {$_.Name -eq "MethodBody"}).InnerText
        $InstallApplicationIdentifier = $enhancedDetectionMethodXML.EnhancedDetectionMethod.Settings.MSI.ProductCode
        $AirWatchProperties.Add("InstallApplicationIdentifier", $InstallApplicationIdentifier)
    }

    Write-Verbose("---------- AW Properties ----------")
    Write-Host $AirWatchProperties | Out-String 
    Write-Verbose("------------------------------")
    Write-Verbose("")

    return $AirWatchProperties
}

<#
  This method maps all the AirWatch Properties extracked and stored in a table to the corresponding JSON value in the AirWatch
  API body.
#>
Function Map-AppDetailsJSON {

    Param(
		[Parameter(Mandatory=$True)]
		[hashtable] $awProperties
	)

    # Map all table values to the AirWatch JSON format
    $applicationProperties = @{
        ApplicationName = $awProperties.ApplicationName
	    AutoUpdateVersion = 'true'
	    BlobId = $awProperties.BlobID
	    DeploymentOptions = @{
		    WhenToInstall = @{
			    DiskSpaceRequiredInKb = 1
			    DevicePowerRequired= 2
			    RamRequiredInMb= 3
		    }
		    HowToInstall= @{
			    AdminPrivileges = "true"
			    DeviceRestart = "DoNotRestart"
			    InstallCommand = $awProperties.InstallCommand
			    InstallContext = $awProperties.InstallContext
			    InstallTimeoutInMinutes = $awProperties.InstallTimeoutInMinutes 
			    InstallerRebootExitCode = $awProperties.InstallerRebootExitCode 
			    InstallerSuccessExitCode = $awProperties.InstallerSuccessExitCode 
			    RetryCount = 3
			    RetryIntervalInMinutes = 5
		    }
		    WhenToCallInstallComplete = @{
			    UseAdditionalCriteria = "false"
			    IdentifyApplicationBy = "DefiningCriteria"
                CriteriaList = @(@{
                    CriteriaType = "AppExists"
				    LogicalCondition = "End"
                    AppCriteria = @{
                        ApplicationIdentifier = $awProperties.InstallApplicationIdentifier
                        VersionCondition = "Any"
                    }			    
                })
			    CustomScript = @{
				    ScriptType = "Unknown"
				    CommandToRunTheScript = "Text value"
				    CustomScriptFileBlodId = 3
				    SuccessExitCode = 1
			    }
		    }
	    }
	    FilesOptions = @{
		    ApplicationUnInstallProcess = @{
			    UseCustomScript = "true"
			    CustomScript =  @{
				    CustomScriptType = "Input"
				    UninstallCommand = $awProperties.UninstallCommandLine
			    }
		    }
	    }
	    Description = $awProperties.Description
	    Developer = $awProperties.Developer
	    DeveloperEmail = ""
	    DeveloperPhone = ""
	    DeviceType = 12
	    EnableProvisioning = "false"
	    FileName = $awProperties.UploadFileName
	    IsDependencyFile = "false"
	    LocationGroupId = $awProperties.LocationGroupId
	    MsiDeploymentParamModel = @{
		    CommandLineArguments = $awProperties.InstallCommand
		    InstallTimeoutInMinutes = $awProperties.InstallTimeoutInMinutes
		    RetryCount = 3
		    RetryIntervalInMinutes = 5
	    }
	    PushMode = 0
	    SupportEmail = ""
	    SupportPhone = ""
	    SupportedModels = @{
		    Model = @(@{
			    ApplicationId = 704
			    ModelId = 50
		    })
	    }
	    SupportedProcessorArchitecture = "x86"
    }

    $json = $applicationProperties | ConvertTo-Json -Depth 10
    Write-Verbose "------- JSON to Post---------"
    Write-Verbose $json
    Write-Verbose "-----------------------------"
    Write-Verbose ""
    
    Return $json
}
