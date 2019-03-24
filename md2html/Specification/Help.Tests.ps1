<#
Module Documentation Tests

Invoke-Pester -Script @{ Path = './Help.Tests.ps1' }
#>
[CmdletBinding()]
param
(
)
#region initialisation
if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent)
{
  $VerbosePreference = 'Continue'
}
#Write-Host $('{0}==>{1}' -f '$VerbosePreference', $VerbosePreference)
$PSBoundParameters | Out-String | Write-Verbose
#endregion
$ModuleSetup = Join-Path $PSScriptRoot "Pester.Tests.Setup.ps1"
if (Test-Path $ModuleSetup) { . $ModuleSetup }

$Script:ModuleRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$Script:ModuleName = $Script:ModuleName = Get-ChildItem $ModuleRoot\*\*.psm1 | Select-object -ExpandProperty BaseName

Describe "Public commands have comment-based or external help" -Tags 'Build' {
    $functions = Get-Command -Module $ModuleName
    $help = foreach ($function in $functions) {
        Get-Help -Name $function.Name
    }

    foreach ($node in $help)
    {
        Context $node.Name {
            It "Should have a Description or Synopsis" {
                ($node.Description + $node.Synopsis) | Should Not BeNullOrEmpty
            }

            It "Should have an Example"  {
                $node.Examples | Should Not BeNullOrEmpty
                $node.Examples | Out-String | Should -Match ($node.Name)
            }

            foreach ($parameter in $node.Parameters.Parameter)
            {
                if ($parameter -notmatch 'WhatIf|Confirm')
                {
                    It "Should have a Description for Parameter [$($parameter.Name)]" {
                        $parameter.Description.Text | Should Not BeNullOrEmpty
                    }
                }
            }
        }
    }
}