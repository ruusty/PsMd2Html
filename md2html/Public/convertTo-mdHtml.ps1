﻿<#
===========================================================================
Filename: md2html.psm1
-------------------------------------------------------------------------
Module Name: md2html
===========================================================================
#>
$ModDir = (Split-Path -parent $MyInvocation.MyCommand.Definition)

function convertTo-mdHtml
{
  [CmdletBinding()]
  param
  (
    [Parameter(Position = 0)]
    [SupportsWildcards()]
    [String[]]$mdFiles = "*.md",
    [Parameter(Mandatory = $false,
                         Position = 1)]
    [String[]]$Path = $(Get-Location),
    [switch]$recurse = $false,
    [string]$CssFile = $CssPath
  )

  #region Initialize
  $builder = New-Object Markdig.MarkdownPipelineBuilder
  # use UseAdvancedExtensions for better error reporting
  $pipeline = [Markdig.MarkdownExtensions]::UseAdvancedExtensions($builder).Build()
  #endregion Initialize

  $psBoundParameters.GetEnumerator() | Sort-Object Name | % { $_.key + " is " + $_.value } | out-string | write-verbose

  Write-Verbose("mdFiles:" + $mdFiles)
  Write-Verbose("Path:" + $Path)
  Write-Verbose("recurse:" + $recurse)
  write-verbose ($("CssFile:" + $CssFile))

  #for each Markdown file in the directory:
  # 1. Use MarkDig to convert the markdown to the HTML body
  # 2. Adding the CSS and in the header
  # 3. Create the file

  $files = $mdfiles | foreach { Get-ChildItem -filter:$_ -recurse:$recurse -Path:$Path }

  $files | foreach {
    if ($_ -ne $null -and [system.io.path]::GetExtension($_) -ine ".html")
    {
      #Output file based on input markdown file
      $htmlFileName = [system.io.path]::ChangeExtension($_.FullName, "html")
      Write-Verbose $($_.FullName + " ==> " + $htmlFileName)
      $sb = New-Object System.Text.StringBuilder
      [void]$sb.AppendLine('<!doctype html>')
      [void]$sb.AppendLine('<html>')
      [void]$sb.AppendLine("<!-- Generated {0} by [Markdig.Markdown]::ToHtml -->" -f $([System.DateTime]::Now))
      [void]$sb.AppendLine("<!-- Generated from {0} -->" -f $file)
      [void]$sb.AppendLine("<head>")
      [void]$sb.AppendLine('<meta charset="utf-8">')
      [void]$sb.AppendLine('<meta http-equiv="x-ua-compatible" content="ie=edge">')
      [void]$sb.AppendLine("<title>$Name</title>")
      [void]$sb.AppendLine('<style type="text/css">')
      [void]$sb.AppendLine((get-content $CssFile))
      [void]$sb.AppendLine('</style>')
      [void]$sb.AppendLine('</head>')
      [void]$sb.AppendLine('<body>')
      try
      {
        if ($_.Length -gt 0)
        {
          [void]$sb.AppendLine($([Markdig.Markdown]::ToHtml($(Get-Content -Raw $_.FullName), $pipeline)))
        }
      }
      catch [ArgumentNullException]
      {
        Write-Warning $_
        Write-Warning $_.ScriptStackTrace
      }
      [void]$sb.AppendLine('</body>')
      [void]$sb.AppendLine('</html>')
      $sb.ToString() | out-file $htmlFileName -Encoding "UTF8"
      $htmlFile = (Get-ChildItem -Path $htmlFileName)
      $htmlFile.lastwritetime = $_.lastwritetime
      $htmlFile.CreationTime = $_.CreationTime
    }
  }
}