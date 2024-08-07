<# 
Taken with love from @juneb_get_help (https://raw.githubusercontent.com/juneb/PesterTDD/master/Module.Help.Tests.ps1)

Invoke-Pester -Script @{ Path = './Help.Tests.ps1';   Parameters = @{ Verbose = $true;  } }
#>
[CmdletBinding()]
param
(
)
#region initialisation
if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
    $VerbosePreference = 'Continue'
}
#Write-Host $('{0}==>{1}' -f '$VerbosePreference', $VerbosePreference)
$PSBoundParameters | Out-String | Write-Verbose
#endregion
#region PortableConfig
$Script:ModuleRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$Script:ModuleName = $Script:ModuleName = Get-ChildItem $ModuleRoot\*\*.psm1 | Select-Object -ExpandProperty BaseName

Write-Verbose $('{0}:{1}' -f '$ModuleName', $ModuleName)

#Load the module from the Build path
$ModulePath = $(Resolve-Path -path $(Join-Path $PSScriptRoot "../../Build/md2html")).Path
Write-Verbose $('{0}:{1}' -f '$ModulePath', $ModulePath)

$ManifestPath = "$ModulePath\$ModuleName.psd1"
Write-Verbose $('{0}:{1}' -f '$ManifestPath', $ManifestPath)
$manifest = Import-PowerShellDataFile -Path $manifestPath
#endregion

# Get module commands
# Remove all versions of the module from the session. Pester can't handle multiple versions.
#Remove-Module -Name $ModuleName -Force
#Import-Module -Name $manifestPath -Force -Verbose:$false -ErrorAction Stop
$commands = Get-Command -Module $ModuleName -CommandType "Cmdlet","Function"  # Not alias

## When testing help, remember that help is cached at the beginning of each session.
## To test, restart session.

foreach ($command in $commands) {
    $commandName = $command.Name

    # The module-qualified command fails on Microsoft.PowerShell.Archive cmdlets
    $help = Get-Help $commandName -ErrorAction SilentlyContinue

    Describe "Test help for $commandName" {

        # If help is not found, synopsis in auto-generated help is the syntax diagram
        It 'should not be auto-generated' {
            $help.Synopsis | Should Not BeLike '*`[`<CommonParameters`>`]*'
        }

        # Should be a description for every function
        It "gets description for $commandName" {
            $help.Description | Should Not BeNullOrEmpty
        }

        # Should be at least one example
        It "gets example code from $commandName" {
            ($help.Examples.Example | Select-Object -First 1).Code | Should Not BeNullOrEmpty
        }

        # Should be at least one example description
        It "gets example help from $commandName" {
            ($help.Examples.Example.Remarks | Select-Object -First 1).Text | Should Not BeNullOrEmpty
        }

        Context "Test parameter help for $commandName" {

            $common = 'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable', 'OutBuffer',
            'OutVariable', 'PipelineVariable', 'Verbose', 'WarningAction', 'WarningVariable', 'Confirm', 'Whatif','ProgressAction'

            $parameters = $command.ParameterSets.Parameters |
            Sort-Object -Property Name -Unique |
            Where-Object { $_.Name -notin $common }
            $parameterNames = $parameters.Name

            ## Without the filter, WhatIf and Confirm parameters are still flagged in "finds help parameter in code" test
            $helpParameters = $help.Parameters.Parameter |
            Where-Object { $_.Name -notin $common } |
            Sort-Object -Property Name -Unique
            $helpParameterNames = $helpParameters.Name

            foreach ($parameter in $parameters) {
                $parameterName = $parameter.Name
                $parameterHelp = $help.parameters.parameter | Where-Object Name -EQ $parameterName

                # Should be a description for every parameter
                It "gets help for parameter: $parameterName : in $commandName" {
                    $parameterHelp.Description.Text | Should Not BeNullOrEmpty
                }

                # Required value in Help should match IsMandatory property of parameter
                It "help for $parameterName parameter in $commandName has correct Mandatory value" {
                    $codeMandatory = $parameter.IsMandatory.toString()
                    $parameterHelp.Required | Should Be $codeMandatory
                }

                # Parameter type in Help should match code
                # It "help for $commandName has correct parameter type for $parameterName" {
                #     $codeType = $parameter.ParameterType.Name
                #     # To avoid calling Trim method on a null object.
                #     $helpType = if ($parameterHelp.parameterValue) { $parameterHelp.parameterValue.Trim() }
                #     $helpType | Should be $codeType
                # }
            }

            foreach ($helpParm in $HelpParameterNames) {
                # Shouldn't find extra parameters in help.
                It "finds help parameter in code: $helpParm" {
                    $helpParm -in $parameterNames | Should Be $true
                }
            }
        }

        <#
        Context "Help Links should be Valid for $commandName" {
            
            if ($help.relatedLinks) {
                $link = $help.relatedLinks.navigationLink.uri
                foreach ($link in $links) {
                    if ($link) {
                        # Should have a valid uri if one is provided.
                        It "[$link] should have 200 Status Code for $commandName" {
                            $Results = Invoke-WebRequest -Uri $link -UseBasicParsing
                            $Results.StatusCode | Should Be '200'
                        }
                    }
                }
           }
        }
        
    #>
     }
    }
