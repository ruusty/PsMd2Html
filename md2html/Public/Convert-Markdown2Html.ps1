﻿function Convert-Markdown2Html
{
  [CmdletBinding(DefaultParameterSetName = 'Path',
                 SupportsShouldProcess = $true)]
  param
  (
    [Parameter(ParameterSetName = 'Path',
               Position = 1)]
    [SupportsWildcards()]
    [string[]]$Path = "*.md",
    [Parameter(ParameterSetName = 'LiteralPath',
               Mandatory = $true,
               ValueFromPipelineByPropertyName = $true,
               Position = 1)]
    [Alias('PSPath')]
    [String[]]$LiteralPath = $null,
    [switch]$Recurse,
    [string]$CssFile = $CssPath
  )
  
  #region Initialize
  $builder = New-Object Markdig.MarkdownPipelineBuilder
  # use UseAdvancedExtensions for better error reporting
  $pipeline = [Markdig.MarkdownExtensions]::UseAdvancedExtensions($builder).Build()
  #endregion Initialize
  
  $psBoundParameters.GetEnumerator() | Sort-Object Name | % { $_.key + " is " + $_.value } | out-string | write-verbose
  
  #for each Markdown file
  # 1. Use MarkDig to convert the markdown to the HTML body
  # 2. Adding the CSS and in the header
  # 3. Create the file

    Write-Verbose -Message ("ParameterSetName:{0}" -f $PsCmdlet.ParameterSetName)
    switch ($PsCmdlet.ParameterSetName)
    {
      "Path"         { $ResolveArgs = @{ Path = $Path }; break }
      "LiteralPath"  { $ResolveArgs = @{ LiteralPath = $LiteralPath }; break }
    }
    
    $ResolveArgs.GetEnumerator() | Sort-Object Name | % { $_.key + " is " + $_.value } | out-string | write-verbose
    
    if ($Recurse)
    {
      $ResolveArgs += @{ recurse = $Recurse }
    }
    $files = Get-ChildItem @ResolveArgs -File -Exclude "*.html"

  foreach ($file in $files)
  {
    if ($file -ne $null -and [system.io.path]::GetExtension($file) -ine ".html")
    {
      $htmlFileName = [system.io.path]::ChangeExtension($file, "html")
      $Name = [system.io.path]::GetFileNameWithoutExtension($file)
      $mdFile = Get-Item -Path $file
      $cmdline = ('{0} ==> {1}' -f $file, $htmlFileName)
      if ($PSCmdlet.ShouldProcess(
          "$cmdline",
          "ConvertFrom-Markdown2Html"))
      {
        #Write-Verbose $($file + " ==> " + $htmlFileName)
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
        if (Test-Path $CssFile) { [void]$sb.AppendLine((get-content $CssFile)) }
        [void]$sb.AppendLine('</style></head>')
        [void]$sb.AppendLine('<body>')
        try
        {
          if ((Get-Item -Path $file).Length -gt 0)
          {
            [void]$sb.AppendLine($([Markdig.Markdown]::ToHtml($(Get-Content -Raw $file), $pipeline)))
          }
        }
        catch [ArgumentNullException]
        {
          Write-Warning $_
          Write-Warning $_.ScriptStackTrace
        }
        finally
        {
          [void]$sb.AppendLine('</body>')
          [void]$sb.AppendLine('</html>')
          $sb.ToString() | out-file $htmlFileName -Encoding "UTF8"
          $htmlFile = (Get-ChildItem -Path $htmlFileName)
          $htmlFile.lastwritetime = $mdFile.lastwritetime
          $htmlFile.CreationTime = $mdFile.CreationTime
        }
      }
    }
  }
}

