

param([Parameter(Mandatory=$true)][string] $accessKey, 
      [Parameter(Mandatory=$true)][string] $secretKey,
      [Parameter(Mandatory=$true)][string] $vmdkImage,
      [Parameter(Mandatory=$true)][string] $bucketName,
      [Parameter(Mandatory=$true)][string]
      [ValidateSet('us-east-1','us-east-2','us-west-1','us-west-2','ap-south-1',
                   'ap-northeast-1','ap-northeast-2','ap-northeast-3','ap-southeast-1','ap-southeast-2',
                   'ca-central-1','cn-north-1','cn-northwest-1','eu-central-1',
                   'eu-west-1', 'eu-west-2', 'eu-west-3','sa-east-1','us-gov-east-1','us-gov-east-2')] $region)

	if (!(Test-path $vmdkImage)) {
		Write-Host "Error: VMDK Image file not found ($vmdkImage)"  -foregroundcolor red -backgroundcolor black
		Exit
	} 

#
# Load the dependent PowerShell Module
#

$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir  = Split-Path -Parent $ScriptPath
$apDeployModule=$ScriptDir+"\ImportUAGasAMI.psm1"

if (!(Test-path $apDeployModule)) {
	Write-host "Error: PowerShell Module $apDeployModule not found." -foregroundcolor red -backgroundcolor black
	Exit
}

import-module $apDeployModule -Force

Write-Host $apDeployModule

$vmdkLocation= [System.IO.Path]::GetDirectoryName($vmdkImage) + "\";

$vmdkImage= [System.IO.Path]::GetFileName($vmdkImage);

Write-Host "Unified Access Gateway (UAG) virtual appliance import script for Amazon EC2"


#Set AWS Credentials and region
SetAWSEnvironmet $accesskey $secretkey $region

## Create a new S3 Bucket if t doesn't exist.
CreateS3Bucket($bucketName)

## Upload .vmdk image into S3 bucket if it is not already there
UploadVMDK $bucketName $vmdkLocation $vmdkImage $region

# Create vmimport role and policy - if the role already exist policy won't be create
if ( (CreateVMImportRoleandPolicy $bucketName) -eq $true) {

   #timer required to allow AWS to attach the policy to a role
   Start-Sleep -Seconds 10

}



# Import the Unified Access Gateway VMDK image into Amazon EBS Snapshot
$impId = ImportVMDK $bucketName $vmdkImage $region

$actualprogress = 0;
$status= "initializing";


DO {
   
   $currentsnapshot = (Get-EC2ImportSnapshotTask -ImportTaskId $impId.ImportTaskId).SnapshotTaskDetail
   $status = $currentsnapshot.Status
   $actualprogress = $currentsnapshot.Progress

   if ($actualprogress) {
      Write-Progress -Activity "Import in Progress $actualprogress%" -Status $status -PercentComplete $actualprogress
   }

   Start-Sleep -Seconds 5

} Until ($status.Equals("completed"))

Write-Progress -Activity "Unified Access Gateway vmdk importing process completed" -PercentComplete 100 -Completed

Write-Host "Unified Access Gateway vmdk importing process completed"


#Register UAG as private AMI into AWS
RegisterAMI $vmdkImage $impId


Write-Host "Unified Access Gateway imported sucessfully and available for deployment on AWS!!!" -foregroundcolor blue -backgroundcolor white
