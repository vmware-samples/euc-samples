#
# Functon to set AWS Credential and Region.
#
function SetAWSEnvironmet {
    param([Parameter(Mandatory=$true)][string] $accesskey,
          [Parameter(Mandatory=$true)][string] $secretkey,
          [Parameter(Mandatory=$true)][string] $region)

    Set-AWSCredential -AccessKey $accesskey -SecretKey $secretkey -StoreAs awsCredentialProfile

    Set-DefaultAWSRegion $region

    Initialize-AWSDefaultConfiguration -ProfileName awsCredentialProfile -Region $region

}

#
# Functon to create new S3 Bucket if it doesn't already exist in S3.
#
function CreateS3Bucket {
   param([Parameter(Mandatory=$true)][string] $bucketName)


    if (! (Test-S3Bucket -BucketName $bucketName)) {
       New-S3Bucket -BucketName $bucketName -Region $region
    } else {
      Write-Warning "S3 Bucket $bucketName already exist" 
    }
}

## 

#
# Function to Upload .vmdk image file into S3 bucket if it doesn't already exist.
#
function UploadVMDK {
   param([Parameter(Mandatory=$true)][string] $bucketName,
         [Parameter(Mandatory=$true)][string] $vmdkLocation,
         [Parameter(Mandatory=$true)][string] $vmdkImage,
         [Parameter(Mandatory=$true)][string] $region)

    $params = @{
        "BucketName"=$bucketName
        "key"="/"+$vmdkImage
        "Region"=$region
    }

    if (! (Get-S3Object @params) ) {

        $params = @{
            "BucketName"=$bucketName
            "File"=$vmdkLocation+$vmdkImage
            "key"="/"+$vmdkImage
            "Region"=$region
        }

        Write-S3Object @params


        Write-Host "VMDK image uploaded sucessfully to the Amazon S3 bucket"
    } else {

        Write-Warning "VMDK File already exist in Amazon S3 bucket"

    }
}



#
# Function to create vmimport Role and policies, if role already exist it won't create the role and policy.
#
function CreateVMImportRoleandPolicy {
   param([Parameter(Mandatory=$true)][string] $bucketName)

## Create vmimport Policy
$importPolicyDocument = @"
{
    "Version":"2012-10-17",
    "Statement":[
        {
            "Sid":"",
            "Effect":"Allow",
            "Principal":{
            "Service":"vmie.amazonaws.com"
            },
            "Action":"sts:AssumeRole",
            "Condition":{
            "StringEquals":{
                "sts:ExternalId":"vmimport"
            }
            }
        }
    ]
}
"@



$importPolicyPermissionDocument = @"
{
    "Version":"2012-10-17",
    "Statement":[
        {
            "Effect":"Allow",
            "Action":[
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket" 
            ],
            "Resource":[
            "arn:aws:s3:::$bucketName",
            "arn:aws:s3:::$bucketName/*"
            ]
        },
        {
            "Effect":"Allow",
            "Action":[
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
            ],
            "Resource":"*"
        }
    ]
}
"@

    try {
       $checkvmimport = (Get-IAMRole vmimport)
       return $false
    } catch {

       New-IAMRole -RoleName vmimport -AssumeRolePolicyDocument $importPolicyDocument

       $PolicyArn = (New-IAMPolicy -PolicyName vmimportpolicy -PolicyDocument $importPolicyPermissionDocument).Arn
       Register-IAMRolePolicy -RoleName vmimport -PolicyArn $PolicyArn

       Write-Host "vmimport role and policy sucessfully created"

       return $true
    }
}


#
# Function to Import Unified Access Gateway VMDK image into Amazon EBS Snapshot
#
function ImportVMDK {
   param([Parameter(Mandatory=$true)][string] $bucketName,
         [Parameter(Mandatory=$true)][string] $vmdkImage,
         [Parameter(Mandatory=$true)][string] $region)

    $params = @{
        "DiskContainer_Format"="VMDK"
        "DiskContainer_S3Bucket"=$bucketName
        "DiskContainer_S3Key"=$vmdkImage
        "Region"=$region
    }
    $impId=Import-EC2Snapshot @params
    $impId
}


#
# Function to register Unified Access Gateway vmdk image as private AMI
#
function RegisterAMI {
   param([Parameter(Mandatory=$true)][string] $vmdkImage,
         [Parameter(Mandatory=$true)][Amazon.EC2.Model.ImportSnapshotResponse] $impId)

    $bdm=New-Object Amazon.EC2.Model.BlockDeviceMapping
    $bd=New-Object Amazon.EC2.Model.EbsBlockDevice
    $bd.SnapshotId=(Get-EC2ImportSnapshotTask -ImportTaskId $impId.ImportTaskId).SnapshotTaskDetail.SnapshotId
    $bd.DeleteOnTermination=$true

    $bdm.DeviceName="/dev/sda1"
    $bdm.Ebs=$bd

    $params = @{
    "BlockDeviceMapping"=$bdm
    "RootDeviceName"="/dev/sda1"
    "Name"=$vmdkImage
    "Architecture"="x86_64"
    "VirtualizationType"="hvm"
    }

    Write-Host "Registering $vmdkImage as AMI"

    $ami = (Register-EC2Image @params)

    Write-Host "AMI Registration completed - AMI ID -> $ami"

}