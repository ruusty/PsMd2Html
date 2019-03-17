<#
  .EXAMPLE
    		 
  
  .NOTES
    https://stackoverflow.com/questions/22269275/accessing-privatedata-during-import-module
    https://social.technet.microsoft.com/Forums/windowsserver/en-US/9620af9a-0323-460c-b3e8-68a73715f99d/module-scoped-variable?forum=winserverpowershell.
#>
function Get-ConfigData {
    [CmdletBinding()]
    Param()
    Begin {}
    Process {
        $MyInvocation.MyCommand.Module.PrivateData.config
        #$MyInvocation.MyCommand.Module.PrivateData.config | format-table | out-string | write-verbose
    }
    End {}
}