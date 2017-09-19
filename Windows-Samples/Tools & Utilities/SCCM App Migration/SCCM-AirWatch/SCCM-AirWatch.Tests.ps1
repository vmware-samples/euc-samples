$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "SCCM XML Extraction" {
    It "processes Adobe sample" {
        # Given
        $adobe = [xml](Get-Content .\SCCM-AirWatch\SampleXML\AdobeStandard.xml)
        
        # When
        $properties = Extract-PackageProperties -SDMPackageXML $adobe

        # Then
        $properties.ApplicationName | Should be "Acrobat Standard 11.0.20"
        
        #$current = $adobe.AppMgmtDigest.DeploymentType | Select-Object -First 1
        #$properties.UploadFilePath | Should be "C:\tmp\Adobe\Acrobat\Standard\11.0.20\"
        
    }
}
