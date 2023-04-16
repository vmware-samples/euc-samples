# Returns the status of Remote Desktop Service
# Return Type: String
# Execution Context: System

$rdp = Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace root\CIMV2\TerminalServices -ErrorAction SilentlyContinue -ErrorVariable err
$rdpstatus = "Undefined"

if ($err.Count -eq 0) { 
    if ($rdp.AllowTSConnections -eq 0) {
      $rdpstatus = "Connections not allowed"
    }
    else {
      $auth = (Get-WmiObject -Class Win32_TSGeneralSetting -Namespace root\CIMV2\TerminalServices -Filter "TerminalName='RDP-tcp'" -ErrorAction SilentlyContinue -ErrorVariable err).UserAuthenticationRequired
      if ($err.Count -eq 0) {
          if ($auth -eq 1) {
             $rdpstatus = "Only Secure Connections allowed" }
          else {
             $rdpstatus = "All Connections allowed"
          }
      }
    }
}
Write-Output $rdpstatus