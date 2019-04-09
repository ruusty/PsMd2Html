<#
  .EXAMPLE
    Get-ConfigData -verbose		 
  
  .NOTES
    https://stackoverflow.com/questions/22269275/accessing-privatedata-during-import-module
    https://social.technet.microsoft.com/Forums/windowsserver/en-US/9620af9a-0323-460c-b3e8-68a73715f99d/module-scoped-variable?forum=winserverpowershell.
  
  .REMARKS
    Needs to be mocked in Pester
#>
function Get-ConfigData {
    [CmdletBinding()]
    Param()
    $config = $MyInvocation.MyCommand.Module.PrivateData.config
    $config | Format-Table | Out-String | Write-Verbose -verbose:$false
    $config
}