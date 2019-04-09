<#
  .SYNOPSIS
    Convert Markdown files to Html
  
  .DESCRIPTION
    Convert Markdown files to Html
  
  .PARAMETER Path
    Wildcard filespec of Markdown files
  
  .PARAMETER LiteralPath
    A description of the LiteralPath parameter.
  
  .PARAMETER Recurse
    Recurse directories for Markdown files using Path
  
  .PARAMETER HighlightWeb
    A description of the HighlightWeb parameter.
  
  .PARAMETER HightlightLocal
    A description of the HightlightLocal parameter.
  
  .EXAMPLE
    Convert-Markdown2Html -Path *.md -whatif

    Whatif Convert *.md files on command line
  
  .EXAMPLE
    "*.md", 'README*.md', "..\Specification\*.md", "..\Specification\*.md" | Convert-Markdown2Html -verbose -recurse

    Markdown file wildcard specification piped to Convert-Markdown2html
    
  .EXAMPLE
    "*.md", 'README*.md', "..\Specification\*.md", "..\Specification\*.md" | Convert-Markdown2Html -verbose -recurse -HighlightWeb
  
        Markdown file wildcard specification piped to Convert-Markdown2html and hilte code

  .EXAMPLE
    Convert-Markdown2Html -path "*.md", 'README*.md', "..\Specification\*.md"

    Many file wildcards on the command line
 
    
#>
function Convert-Markdown2Html {
    [CmdletBinding(DefaultParameterSetName = 'Path',
        SupportsShouldProcess = $true)]
    param
    (
        [Parameter(ParameterSetName = 'Path',
            Mandatory = $false,
            ValueFromPipeline = $true,
            Position = 1)]
        [SupportsWildcards()]
        [string[]]$Path = "*.md",
        [Parameter(ParameterSetName = 'LiteralPath',
            Mandatory = $false,
            Position = 1)]
        [Alias('PSPath')]
        [String[]]$LiteralPath = $null,
        [switch]$Recurse,
        [Alias('Hilite')]
        [switch]$HighlightWeb,
        [switch]$HightlightLocal
    )
  
    Begin {
        $IsVerbose = $false
        if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
            $IsVerbose = $true
        }
        #region setup
        # Get the command name
        $CommandName = $PSCmdlet.MyInvocation.InvocationName;
        # Get the list of parameters for the command
        "${CommandName}: Input", (((Get-Command -Name ($PSCmdlet.MyInvocation.InvocationName)).Parameters) |
            ForEach-Object { Get-Variable -Name $_.Values.Name -ErrorAction SilentlyContinue; } |
            Format-Table -AutoSize @{ Label = "Name"; Expression = { $_.Name }; }, @{ Label = "Value"; Expression = { (Get-Variable -Name $_.Name -EA SilentlyContinue).Value }; }) |
        Out-String | Write-Verbose
        #endregion

        $config = Get-ConfigData
        #$config | format-table | out-string -width 80 | write-Verbose
        [string]$CssPath = $(Join-Path -path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath  $config.CssPath)
        [string]$HighlightCssPath = $(Join-Path -path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath  $config.HighlightJsCssPath)
        [string]$HighlightJsPath = $config.HighlightJsPath
        [string]$HighlightJsPathLocal = $config.HighlightJsPathLocal
        "Configuration" + (@('CssPath', 'HighlightCssPath', 'HighlightJsPathLocal', 'HighlightJsPath') | Get-Variable -ea Continue | Sort-Object -Property name -CaseSensitive | Format-Table -property name, value -autosize | Out-String -Width 80) | Write-Verbose
    }
    Process {
        Write-Verbose -Message ("ParameterSetName:{0}" -f $PsCmdlet.ParameterSetName)
        switch ($PsCmdlet.ParameterSetName) {
            "Path" {
                $GetChildItemArgs = @{ Path = $Path }; break
            }
            "LiteralPath" {
                $GetChildItemArgs = @{ LiteralPath = $LiteralPath }; break
            }
        }
    
        if ($Recurse) {
            $GetChildItemArgs += @{ recurse = $Recurse }
        }
    
        #$GetChildItemArgs.GetEnumerator() | Sort-Object Name | ForEach-Object { $_.key + " is " + $_.value } | out-string | write-verbose
    
        $CMArgs = @{
            CssPath          = $CssPath
            HighlightCssPath = $HighlightCssPath
            Verbose          = $IsVerbose
            whatif           = $WhatIfPreference
        }
    
        if ($HighlightWeb) {
            $CMArgs.HighlightJsPath = $HighlightJsPath;
        }
        if ($HightlightLocal) {
            $CMArgs.HighlightJsPath = $HighlightJsPathLocal;
        }
        Get-ChildItem @GetChildItemArgs -File -Exclude "*.html" | Sort-Object -unique | Convert-Markdown @CMArgs
    }
}

