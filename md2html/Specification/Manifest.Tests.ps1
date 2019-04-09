[CmdletBinding()]
param
(
)
<#
Module Manifest Tests

Invoke-Pester -Script @{ Path = './Manifest.Tests.ps1' }

Invoke-Pester -Script @{ Path = './Manifest.Tests.ps1';   Parameters = @{ Verbose = $true;  } }

#>
#region initialisation
$IsVerbose = $false
if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
    $VerbosePreference = 'Continue'
    $IsVerbose = $true
}

#Write-Host $('{0}==>{1}' -f '$VerbosePreference', $VerbosePreference)
$PSBoundParameters | Out-String | Write-Verbose
#endregion

$Script:ModuleRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$Script:ModuleName = $Script:ModuleName = Get-ChildItem $ModuleRoot\*\*.psm1 | Select-Object -ExpandProperty BaseName

Write-Verbose $('{0}:{1}' -f '$ModuleName', $ModuleName)

$ModulePath = (Resolve-Path -path $(Join-Path $PSScriptRoot "..")).Path
Write-Verbose $('{0}:{1}' -f '$ModulePath', $ModulePath)

$ManifestPath = "$ModulePath\$ModuleName.psd1"
Write-Verbose $('{0}:{1}' -f '$ManifestPath', $ManifestPath)
#region setup dependencies

$ModuleSetup = Join-Path $PSScriptRoot "Pester.Tests.Setup.ps1"
if (Test-Path $ModuleSetup) { . $ModuleSetup -verbose:$isVerbose }


#Explicitly import the module for testing
$(Get-Module $ModuleName).ExportedCommands | Sort-Object | Out-String | Write-Verbose


# test the module manifest - exports the right functions, processes the right formats, and is generally correct
# https://mattmcnabb.github.io/pester-testing-your-module-manifest


Describe "Manifest" {
  
    $ManifestHash = Invoke-Expression (Get-Content $ManifestPath -Raw)
  
    It "has a valid manifest" {
        {
            $null = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }
  
    It "has a valid root module" {
        $ManifestHash.RootModule | Should Be "$ModuleName.psm1"
    }
  
    It "has a valid Description" {
        $ManifestHash.Description | Should Not BeNullOrEmpty
    }
  
    It "has a valid guid" {
        $ManifestHash.Guid | Should Match '[A-Za-z0-9]{4}([A-Za-z0-9]{4}\-?){4}[A-Za-z0-9]{12}' #'90EB765F-A568-486B-2DAA-E60C4C75D5AB'
    }
  
    #  It "has a valid prefix" {
    #    $ManifestHash.DefaultCommandPrefix | Should Not BeNullOrEmpty
    #  }
  
    It "has a valid copyright" {
        $ManifestHash.CopyRight | Should Not BeNullOrEmpty
    }
    
    It "Should exports cmdlet functions" {
        $numCmdlet = 0
        $ExportedCommands = $(Get-Module $ModuleName).ExportedCommands
        $CmdletCount = (($ExportedCommands.GetEnumerator() | ForEach-Object { $_.value } | Where-Object { ($_.CommandType -eq 'Cmdlet') })| measure-object).Count
        $CmdletCount | Should be $numCmdlet
    }
  
  
    It "Should export public script functions" {
        $numFunctions = 1
        $ExportedCommands = $(Get-Module $ModuleName).ExportedCommands
        $FunctionCount = (($ExportedCommands.GetEnumerator() | ForEach-Object { $_.value } | Where-Object { ($_.CommandType -eq 'Function') }) | Measure-Object).Count
        $FunctionCount | Should be $numFunctions
    
    }
  
    # Check all files in public have correct function name
    It "Files in public have Should have correct function name" {
        $ExportedCommands = $(Get-Module $ModuleName).ExportedCommands
        $Functions = $ExportedCommands.GetEnumerator() | ForEach-Object { $_.value } | Where-Object { ($_.CommandType -eq 'Function') }
        foreach ($FunctionName in $Functions) {
            $srcFile = Join-Path "$ModulePath\Public" "$FunctionName.ps1"
            Test-Path -Path $srcFile | Should Be $true
        }
    }
}
