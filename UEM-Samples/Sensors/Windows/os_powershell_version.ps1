# Description: Returns the PowerShell Version in Major.Minor.Build.Revision format
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$ps = $PSVersionTable.PSVersion
Return "$($ps.Major).$($ps.Minor).$($ps.Build).$($ps.Revision)"

