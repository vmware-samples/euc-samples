# Description: This powershell script grants the "Log on as a Service" User Rights Assignment to the user specified by the $ServiceAccount param
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Timeout: 30
# Variables: RegPath,"Registry::HKLM:\SOFTWARE\AIRWATCH"; Regkey,"EAUATScript"; RegValue,"UAT Script run in System Context"

Add-Type @'
using System;
using System.Runtime.InteropServices;

public enum LSA_AccessPolicy : long
{
    // Other values omitted for clarity
    POLICY_ALL_ACCESS = 0x00001FFFL
}

[StructLayout(LayoutKind.Sequential)]
public struct LSA_UNICODE_STRING
{
    public UInt16 Length;
    public UInt16 MaximumLength;
    public IntPtr Buffer;
}

[StructLayout(LayoutKind.Sequential)]
public struct LSA_OBJECT_ATTRIBUTES
{
    public UInt32 Length;
    public IntPtr RootDirectory;
    public LSA_UNICODE_STRING ObjectName;
    public UInt32 Attributes;
    public IntPtr SecurityDescriptor;
    public IntPtr SecurityQualityOfService;
}

public static partial class AdvAPI32 {
    [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
    public static extern uint LsaOpenPolicy(
        ref LSA_UNICODE_STRING SystemName,
        ref LSA_OBJECT_ATTRIBUTES ObjectAttributes,
        uint DesiredAccess,
        out IntPtr PolicyHandle);

    [DllImport("advapi32.dll")]
    public static extern Int32 LsaClose(IntPtr ObjectHandle);

    [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
    public static extern uint LsaAddAccountRights(
        IntPtr PolicyHandle,
        byte[] AccountSid,
        LSA_UNICODE_STRING[] UserRights,
        uint CountOfRights);
}
'@

function Get-LsaPolicyHandle() {
  $system = New-Object LSA_UNICODE_STRING
  $attrib = New-Object LSA_OBJECT_ATTRIBUTES -Property @{
      Length = 0
      RootDirectory = [System.IntPtr]::Zero
      Attributes = 0
      SecurityDescriptor = [System.IntPtr]::Zero
      SecurityQualityOfService = [System.IntPtr]::Zero
  };

  $handle = [System.IntPtr]::Zero

  $hr = [AdvAPI32]::LsaOpenPolicy([ref] $system, [ref]$attrib, [LSA_AccessPolicy]::POLICY_ALL_ACCESS, [ref]$handle)

  if (($hr -ne 0) -or ($handle -eq [System.IntPtr]::Zero)) {
      Write-Error "Failed to open Local Security Authority policy. Error code: $hr"
  } else {
      $handle
  }
}

function New-Right([string]$rightName){
  $unicodeCharSize = 2
  New-Object LSA_UNICODE_STRING -Property @{
      Buffer = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($rightName)
      Length = $rightName.Length * $unicodeCharSize
      MaximumLength = ($rightName.Length + 1) * $unicodeCharSize
  }
}

function Grant-Rights([System.IntPtr]$policyHandle, [byte[]]$sid, [LSA_UNICODE_STRING[]]$rights) {
  $result = [AdvAPI32]::LsaAddAccountRights($policyHandle, $sid, $rights, 1)
  if ($result -ne 0) {
      Write-Error "Failed to grant right. Error code $result"
  } 
}

function Grant-LogonAsServiceRight([byte[]]$sid) { 
  $logonAsServiceRightName = "SeServiceLogonRight"

  try {
      $policy = Get-LsaPolicyHandle
      $right = New-Right $logonAsServiceRightName
      Grant-Rights $policy $sid @($right)
  }
  finally {
      if($null -ne $policy){
          [AdvAPI32]::LsaClose($policy) | Out-Null
      }
  }
}

function Get-SidForUser {
  param ([string]$UserName)
  $sid = ((New-Object System.Security.Principal.NTAccount($UserName)).Translate([System.Security.Principal.SecurityIdentifier]))
  [byte[]]$bytes = New-Object byte[] $sid.BinaryLength;
  $sid.GetBinaryForm($bytes, 0);
  return $bytes
}

Grant-LogonAsServiceRight (Get-SidForUser -UserName $env:ServiceAccount)