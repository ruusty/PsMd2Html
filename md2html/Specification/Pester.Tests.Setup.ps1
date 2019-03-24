[CmdletBinding()]
param
(
)
<#
Load the Module based on this file's location
#>
$IsVerbose=$false
if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent)
{
  $VerbosePreference = 'Continue'
  $IsVerbose=$true
}
$Script:ModuleRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$Script:ModuleName = $Script:ModuleName = Get-ChildItem $ModuleRoot\*\*.psm1 | Select-object -ExpandProperty BaseName
Remove-Module -Name $Script:ModuleRoot -Force -ErrorAction SilentlyContinue -verbose:$IsVerbose
Import-Module -Name $(Get-ChildItem "$PSScriptRoot\..\*.psm1").Fullname -Force -verbose:$IsVerbose

