Function Get-TemplateFilePath {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $FileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $FileDialog.InitialDirectory = $env:HOMEPATH
    $FileDialog.ShowDialog() | Out-Null
    $FileDialog.FileName
}

Function Get-TemplateRules {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $True, HelpMessage = "Please provide the file path to the Rule Template Spreadsheet")]
        [ValidateNotNullorEmpty()]
        $FilePath
    )

    $Excel = New-Object -ComObject excel.application
    $Book = $Excel.Workbooks.Open($FilePath)
    $Excel.Visible = $False
    
    # Sheet indexing begins at 1
    $Sheet = $Book.Sheets.Item(1)

    $StartRow = 2
    $EndRow = ($Sheet.UsedRange.Rows).Count

    $DataArray = @()

    for($Row = $StartRow; $Row -le $EndRow; $Row++) {
    Write-Host "Row $($Row)"
        $Name = $Sheet.Cells.Item($Row, 1).text
        $AppPath = $Sheet.Cells.Item($Row, 2).text
        $Enabled = $Sheet.Cells.Item($Row, 3).text
        $ActionType = $Sheet.Cells.Item($Row, 4).text
        $Direction = $Sheet.Cells.Item($Row, 5).text

        $obj = New-Object PSCustomObject

        $obj | Add-Member -type NoteProperty -Name "Name" -Value $Name
        $obj | Add-Member -type NoteProperty -Name "AppPath" -Value $AppPath
        $obj | Add-Member -type NoteProperty -Name "Enabled" -Value $Enabled
        $obj | Add-Member -type NoteProperty -Name "ActionType" -Value $ActionType
        $obj | Add-Member -type NoteProperty -Name "Direction" -Value $Direction
        
        $DataArray += $obj
    }

    # Close workbook and excel without saving
    $Book.Close($False)
    $Excel.quit()

    Return $DataArray

}

Function New-MDMFirewallRule {
    Param(
        $rule,
        $cmdID
    )

    $Name = $rule.Name
    $NodeName = $Name -replace '\s', ''
    $FilePath = $rule.AppPath
    $Enabled = $rule.Enabled
    $ActionType = $rule.ActionType
    $Direction = $rule.Direction


    $xmlTemplate = @"
<Replace>
    <CmdID>$cmdID</CmdID>
    <Item>
	<Target>
	    <LocURI>
		./Vendor/MSFT/Firewall/MdmStore/FirewallRules/$NodeName/App/FilePath
	    </LocURI>
	</Target>
	<Meta>
	    <Format xmlns="syncml:metinf">chr</Format>
	    <Type>text/plain</Type>
	</Meta>
	<Data>$Filepath</Data>
    </Item>
</Replace>
<Replace>
    <CmdID>$($cmdID + 1)</CmdID>
    <Item>
	<Target>
	    <LocURI>
		./Vendor/MSFT/Firewall/MdmStore/FirewallRules/$NodeName/Enabled
	    </LocURI>
	</Target>
	<Meta>
	    <Format xmlns="syncml:metinf">bool</Format>
	    <Type>text/plain</Type>
	</Meta>
	<Data>$Enabled</Data>
    </Item>
</Replace>
<Replace>
    <CmdID>$($cmdID + 2)</CmdID>
    <Item>
	<Target>
	    <LocURI>
		./Vendor/MSFT/Firewall/MdmStore/FirewallRules/$NodeName/Action/Type
	    </LocURI>
	</Target>
	<Meta>
	    <Format xmlns="syncml:metinf">int</Format>
	    <Type>text/plain</Type>
	</Meta>
	<Data>$ActionType</Data>
    </Item>
</Replace>
<Replace>
    <CmdID>$($cmdID + 3)</CmdID>
    <Item>
	<Target>
	    <LocURI>
		./Vendor/MSFT/Firewall/MdmStore/FirewallRules/$NodeName/Name
	    </LocURI>
	</Target>
	<Meta>
	    <Format xmlns="syncml:metinf">chr</Format>
	    <Type>text/plain</Type>
	</Meta>
	<Data>$Name</Data>
    </Item>
</Replace>
<Replace>
    <CmdID>$($cmdID + 4)</CmdID>
    <Item>
	<Target>
	    <LocURI>
		./Vendor/MSFT/Firewall/MdmStore/FirewallRules/$NodeName/Direction
	    </LocURI>
	</Target>
	<Meta>
	    <Format xmlns="syncml:metinf">chr</Format>
	    <Type>text/plain</Type>
	</Meta>
	<Data>$Direction</Data>
    </Item>
</Replace>
"@

    Return $xmlTemplate
}

Function New-MDMRemoveRule {
    Param($rule, $cmdID)

$delete = @"
<Delete>
    <CmdID>$cmdID</CmdID>
    <Item>
    <Target>
        <LocURI>
        ./Vendor/MSFT/Firewall/MdmStore/FirewallRules/$($rule.Name -replace '\s', '')
        </LocURI>
    </Target>
    </Item>
</Delete>
"@

    Return $delete
}

Function Export-MDMFirewallXML {
    Param($Rules)

    $cmdID = 10
    $xmlStr = ""

    foreach($rule in $Rules) {
        $xml = New-MDMFirewallRule -rule $rule -cmdID $cmdID
        $cmdID = $cmdID + 5
        $xmlStr += $xml
    }

    $xmlStr > $PSScriptRoot\MDMAddFirewallRules.xml
}

Function Export-MDMRemoveFirewallRulesXML {
    Param($Rules)

    $cmdID = 2
    $remove = ""

    foreach($rule in $Rules) {
        $xml = New-MDMRemoveRule -rule $rule -cmdID $cmdID
        $cmdID += 1
        $remove += $xml
    }

    $remove > $PSScriptRoot\MDMRemoveFirewallRules.xml
}


# MAIN
$fileName = Get-TemplateFilePath

$rules = Get-TemplateRules -FilePath $fileName

Export-MDMFirewallXML -Rules $rules
Export-MDMRemoveFirewallRulesXML -Rules $rules