<#
===========================================================================
Filename: md2html.psm1
-------------------------------------------------------------------------
Module Name: md2html
===========================================================================
#>
$ModDir = (Split-Path -parent $MyInvocation.MyCommand.Definition)

function convertTo-mdHtml
{
  param (
    [Parameter(Position = 0)]
    [String[]]$mdFiles = $("*.md"),
    [Parameter(Position = 1, Mandatory = $false)]
    [String[]]$Path = $(Get-Location),
    [switch]$recurse = $false
  )
  begin
  {
    $builder = New-Object Markdig.MarkdownPipelineBuilder
    # use UseAdvancedExtensions for better error reporting
    $pipeline = [Markdig.MarkdownExtensions]::UseAdvancedExtensions($builder).Build()
  }
  Process
  {

    Write-Verbose("mdFiles:" + $mdFiles)
    Write-Verbose("Path:" + $Path)
    Write-Verbose("recurse:" + $recurse)

    $CssFile = $ModDir + "/markdownpad-github.css"
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
        [void]$sb.AppendLine('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">')
        [void]$sb.AppendLine('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">')
        [void]$sb.AppendLine("<!-- Generated {0} by [Markdig.Markdown]::ToHtml -->" -f $([System.DateTime]::Now))
        [void]$sb.AppendLine('<style type="text/css">')
        [void]$sb.AppendLine((get-content $cssFile))
        [void]$sb.AppendLine('</style>')
        [void]$sb.AppendLine('<head>')
        [void]$sb.AppendLine("<title>$_</title>")
        [void]$sb.AppendLine('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />')
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
        $htmlFile = (ls $htmlFileName)
        $htmlFile.lastwritetime = $_.lastwritetime
        $htmlFile.CreationTime = $_.CreationTime
      }
    }
  }
}

Export-ModuleMember -Function convertTo-mdHtml



