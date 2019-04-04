<#
Invoke-Pester -testname "noop*" -Script @{ Path = './md2html.Module.Tests.ps1'; Parameters = @{ Verbose = $true;  }}
#>
[CmdletBinding()]
param
(
)
#region initialisation
$IsVerbose=$false
if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent)
{
  $VerbosePreference = 'Continue'
  $IsVerbose=$true
}
#Write-Host $('{0}==>{1}' -f '$VerbosePreference', $VerbosePreference)
$PSBoundParameters | Out-String | Write-Verbose
#endregion

#region PortableConfig
$here = $PSScriptRoot
$Script:ModuleRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$Script:ModuleName = $Script:ModuleName = Get-ChildItem $ModuleRoot\*\*.psm1 | Select-object -ExpandProperty BaseName
$ModulePath = (Resolve-Path -path $(Join-Path $PSScriptRoot "..")).ProviderPath
$ManifestPath = "$ModulePath\$ModuleName.psd1"
$ModuleSetup = Join-Path $PSScriptRoot "Pester.Tests.Setup.ps1"

@('here','ModuleRoot','ModuleName','ModulePath','ManifestPath','ModuleSetup') | Sort-Object -Unique |
 ForEach-Object{ Get-Variable -Name $_ -ErrorAction SilentlyContinue; } |Format-Table -AutoSize @{ Label = "Name"; Expression = { $_.Name }; }, @{ Label = "Value"; Expression = {(Get-Variable -Name $_.Name -EA SilentlyContinue).Value }; } | Out-String | write-verbose -verbose:$IsVerbose
#endregion

if (Test-Path $ModuleSetup) { . $ModuleSetup -verbose:$IsVerbose }

#region setup dependencies

$UncPath = Join-Path "$env:TEMP\$ModuleName" $([System.IO.Path]::GetRandomFileName())

$dependencies = @(
  @{
    label    = "Create data directory $UncPath"
    Test     = { (Test-Path -Path $UncPath -PathType Container) }
    Action   = {
      [void](mkdir $UncPath)
      copy-item -Path "$PSScriptRoot\test?" -destination $UncPath -Container -Recurse -Exclude "*.html"-verbose:$IsVerbose
      copy-item -path "$PSScriptRoot\..\example\*.md" -destination $UncPath\test5 -Container -Recurse -Exclude "*.html"-verbose:$IsVerbose
      Get-ChildItem -path $UncPath -include "*.html" -recurse | remove-item -confirm:$false
    }
  }
)

foreach ($dep in $dependencies)
{
  Write-Host $("Checking {0}" -f $dep.Label)
  & $dep.Action
  if (-not (& $dep.Test))
  {
    throw "The check: $($dep.Label) failed. Halting all tests."
  }
}


<#
invoke-Pester -testname "Convert-Markdown2Html" -Script @{ Path = './md2html.Module.Tests.ps1'; Parameters = @{ Verbose = $true;} }
#>

Describe 'Convert-Markdown2Html' {
    <#
  Pester changes Get-ConfigData and returns null, so need to mock with this taken from the Module Manifest md2html.psd1 
  PrivateData hashtable
  #>
    mock -CommandName 'Get-ConfigData' -ModuleName 'md2html' -MockWith {
        @{
            None                 = "data/none.css"
            CssPath              = "data/markdownpad-github.min.css"
            HighlightJsCssPath   = "data/vs.min.css"
            #Highlight local
            HighlightJsPathLocal = 'file://corp/it/MKT/DEPT/IT%20Spatial/OMS%20GIS/libs/highlight.js/highlight.pack.js'
            #Highlight on the Web
            HighlightJsPath      = 'https://highlightjs.org/static/highlight.pack.js'
        }
    }
    It "Converts markdown multiple file(s) from <Path> to <ReferencePath> (test1)" `
        -TestCases @(
        @{Path = 'test1/*.md'; ReferencePath = 'test1/*.html'}
    ) `
    {
        param($Path, $ReferencePath)

        $testPath = Join-Path $SCRIPT:UncPath -ChildPath $Path
        #$refPath  = Join-Path $SCRIPT:UncPath -ChildPath $ReferencePath

        md2html\Convert-Markdown2Html -Path $testPath -verbose:$IsVerbose
       
        Get-ChildItem -path $testPath | ForEach-Object {
            $result = [System.IO.Path]::ChangeExtension($_.FullName, '.html')
            $result | Should -Exist
        }

        #$refFileContents = Get-Content -LiteralPath $refPath -Encoding UTF8 | Out-String
        #Get-Content -LiteralPath $ResultPath -Encoding UTF8 | Out-String | Should -BeExactly $refFileContents
    }
     
    It "Should Not convert non-md files (test0)" `
        -TestCases @(
        @{Path = 'test0/*.md;test0/*.txt'; ReferencePath = 'test0/*.html'}
    ) `
    {
        param($Path, $ReferencePath)
        $testPath = $Path -split ';' | % {Join-Path -Path $SCRIPT:UncPath -ChildPath $_}
        #$refPath  = Join-Path $SCRIPT:UncPath -ChildPath $ReferencePath
        $testPath | write-verbose -verbose:$IsVerbose
        md2html\Convert-Markdown2Html -Path $testPath -verbose:$IsVerbose

        Get-ChildItem -path $testPath | ForEach-Object {
            $result = [System.IO.Path]::ChangeExtension($_.FullName, '.html')
            $x = [System.IO.Path]::GetExtension($_.FullName)
            switch ($x) {
                '.md' {  $result | Should  Exist}
                '.txt' {  $result | Should not Exist}
                Default {}
            }
          
        }
    }


    It "Create and modify date time should be same as md (test2)" `
        -TestCases @(
        @{Path = 'test2/*.md;test2/*.txt'; ReferencePath = 'test2/*.html'}
    ) `
    {
        param($Path, $ReferencePath)
        $testPath = $Path -split ';' | % {Join-Path -Path $SCRIPT:UncPath -ChildPath $_}
        #$refPath  = Join-Path $SCRIPT:UncPath -ChildPath $ReferencePath
        $testPath | write-verbose -verbose:$IsVerbose
        md2html\Convert-Markdown2Html -Path $testPath -verbose:$IsVerbose

        Get-ChildItem -path $testPath | ForEach-Object {
            $result = [System.IO.Path]::ChangeExtension($_.FullName, '.html')
            $x = [System.IO.Path]::GetExtension($_.FullName)
            switch ($x) {
                '.md' {  
                    $result | Should  Exist
                    ( $_.lastwritetime -eq (Get-ChildItem -Path $result).lastwritetime -and
                        $_.CreationTime -eq (Get-ChildItem -Path $result).CreationTime)
                }
                '.txt' {  $result | Should not Exist}
                Default {}
            }
         
        }
    }
    



    It "Should recurse folders (test3)" `
        -TestCases @(
        @{Path = 'test3/*.md'; ReferencePath = 'test3/*.html'}
    ) `
    {
        param($Path, $ReferencePath)
        $testPath = $Path -split ';' | ForEach-Object {Join-Path -Path $SCRIPT:UncPath -ChildPath $_}
        $refPath = Join-Path $SCRIPT:UncPath -ChildPath $ReferencePath
        $testPath | write-verbose -verbose:$IsVerbose
        md2html\Convert-Markdown2Html -Path $testPath -recurse -verbose:$IsVerbose

        $mdFiles = Get-ChildItem -path $testPath -Recurse 

        $mdFiles| ForEach-Object {
            $result = [System.IO.Path]::ChangeExtension($_.FullName, '.html')
            $x = [System.IO.Path]::GetExtension($_.FullName)
            switch ($x) {
                '.md' {  
                    $result | Should  Exist
                    ( $_.lastwritetime -eq (Get-ChildItem -Path $result).lastwritetime -and $_.CreationTime -eq (Get-ChildItem -Path $result).CreationTime)
                }
                '.txt' {  $result | Should not Exist}
                Default {}
            }
         
        }

        $htmlFiles = Get-ChildItem -path $refPath -Recurse 
        $htmlFiles.Count | Should -BeExactly $mdFiles.Count
    }


    #Need to support this in build scriptsconvertto-mdhtml
   
    It "Should support ConvertTo-mdHtml (test4)" `
        -TestCases @(
        @{Path = 'test4/*.md'; ReferencePath = 'test4/*.html'}
    ) `
    {
        param($Path, $ReferencePath)
        $testPath = $Path -split ';' | ForEach-Object {Join-Path -Path $SCRIPT:UncPath -ChildPath $_}
        $refPath = Join-Path $SCRIPT:UncPath -ChildPath $ReferencePath
        $testPath | write-verbose -verbose:$IsVerbose
        ConvertTo-mdHtml -Path $testPath -recurse -verbose:$IsVerbose

        $mdFiles = Get-ChildItem -path $testPath -Recurse 

        $mdFiles| ForEach-Object {
            $result = [System.IO.Path]::ChangeExtension($_.FullName, '.html')
            $x = [System.IO.Path]::GetExtension($_.FullName)
            switch ($x) {
                '.md' {  
                    $result | Should  Exist
                    ( $_.lastwritetime -eq (Get-ChildItem -Path $result).lastwritetime -and $_.CreationTime -eq (Get-ChildItem -Path $result).CreationTime)
                }
                '.txt' {  $result | Should not Exist}
                Default {}
            }
         
        }

        $htmlFiles = Get-ChildItem -path $refPath -Recurse 
        $htmlFiles.Count | Should -BeExactly $mdFiles.Count
    }
   
    # It should highlight
    It "Should Support code highlight (test5)" `
        -TestCases @(
        @{Path = 'test5/*.md'; ReferencePath = 'test5/*.html'}
    ) `
    {
        param($Path, $ReferencePath)
        $testPath = $Path -split ';' | ForEach-Object {Join-Path -Path $SCRIPT:UncPath -ChildPath $_}
        $refPath = Join-Path $SCRIPT:UncPath -ChildPath $ReferencePath
        $testPath | write-verbose -verbose:$IsVerbose
        ConvertTo-mdHtml -Path $testPath -Hilite -recurse -verbose:$IsVerbose

        $mdFiles = Get-ChildItem -path $testPath -Recurse 

        $mdFiles| ForEach-Object {
            $result = [System.IO.Path]::ChangeExtension($_.FullName, '.html')
            $x = [System.IO.Path]::GetExtension($_.FullName)
            switch ($x) {
                '.md' {  
                    $result | Should  Exist
                    ( $_.lastwritetime -eq (Get-ChildItem -Path $result).lastwritetime -and $_.CreationTime -eq (Get-ChildItem -Path $result).CreationTime)
                }
                '.txt' {  $result | Should not Exist}
                Default {}
            }
         
        }
        $htmlFiles = Get-ChildItem -path $refPath -Recurse 
        $htmlFiles.Count | Should -BeExactly $mdFiles.Count
    }

   
    It "Should convert empty md (test6)" `
        -TestCases @(
        @{Path = "test6\*.md"; ReferencePath = "test6\*.html"}
    ) `
    {
        param($Path, $ReferencePath)
        $testPath = $Path -split ';' | ForEach-Object {Join-Path -Path $SCRIPT:UncPath -ChildPath $_}
        $refPath = Join-Path $SCRIPT:UncPath -ChildPath $ReferencePath
        $testPath | write-verbose -verbose:$IsVerbose
        $testPath | ConvertTo-mdHtml -Hilite -recurse -verbose:$IsVerbose

        $mdFiles = Get-ChildItem -path $testPath -Recurse 

        $mdFiles| ForEach-Object {
            $result = [System.IO.Path]::ChangeExtension($_.FullName, '.html')
            $x = [System.IO.Path]::GetExtension($_.FullName)
            switch ($x) {
                '.md' {  
                    $result | Should  Exist
                    ( $_.lastwritetime -eq (Get-ChildItem -Path $result).lastwritetime -and $_.CreationTime -eq (Get-ChildItem -Path $result).CreationTime)
                }
                '.txt' {  $result | Should not Exist}
                Default {}
            }
         
        }
        $htmlFiles = Get-ChildItem -path $refPath -Recurse 
        $htmlFiles.Count | Should -BeExactly $mdFiles.Count
    }
 
}

