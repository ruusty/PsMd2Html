<#
  .SYNOPSIS
    Convert Markdown files to Html
  
  .DESCRIPTION
    Convert Markdown files to Html using Markdig
  
  .PARAMETER Path
    FileInfo collection of Markdown files
  
  .PARAMETER CssPath
    Path to the CSS file that is included in the output html
  
  .PARAMETER HighlightCssPath
    Path Highlight Javascript CSS file that is included in the output html
  
  .PARAMETER HighlightJsPath
    Path of the HighLight Javascript library
    Referenced in the html header 
     
  
  .EXAMPLE
    		PS C:\> get-childitem readme.md | Convert-Markdown
  
  .NOTES
    Additional information about the function.
#>
function Convert-Markdown
{
  [CmdletBinding(SupportsShouldProcess = $true)]
  param
  (
    [Parameter(Mandatory = $true,
               ValueFromPipeline = $true,
               Position = 1)]
    [system.IO.FileInfo[]]$Path,
    [string]$CssPath ,
    [string]$HighlightCssPath,
    [string]$HighlightJsPath
  )
  Begin
  {
    #region Initialize
        [string[]]$advancedMarkdownExtensions = @(
            'abbreviations' ## .UseAbbreviations()
            ##'autoidentifiers' ## .UseAutoIdentifiers()
            'citations' ## .UseCitations()
            'customcontainers' ## .UseCustomContainers()
            'definitionlists' ## .UseDefinitionLists()
            'emphasisextras' ## .UseEmphasisExtras()
            'figures' ## .UseFigures()
            'footers' ## .UseFooters()
            'footnotes' ## .UseFootnotes()
            'gridtables' ## .UseGridTables()
            'mathematics' ## .UseMathematics()
            'medialinks' ## .UseMediaLinks()
            'pipetables' ## .UsePipeTables()
            'listextras' ## .UseListExtras()
            'tasklists' ## .UseTaskLists()
            'diagrams' ## .UseDiagrams()
            'autolinks' ## .UseAutoLinks()
            'attributes' ## .UseGenericAttributes();
        )
        <## configure the Markdig pipeline
        [Markdig.MarkdownPipelineBuilder]$pipelineBuilder = (New-Object Markdig.MarkdownPipelineBuilder)
        Write-Verbose "Adding Markdig parser extensions .UseAutoIdentifiers(GitHub)"
        $pipelineBuilder = [Markdig.MarkDownExtensions]::UseAutoIdentifiers($pipelineBuilder, [Markdig.Extensions.AutoIdentifiers.AutoIdentifierOptions]::GitHub)
        Write-Verbose "Adding Markdig parser extensions $advancedMarkdownExtensions"
        $pipelineBuilder = [Markdig.MarkDownExtensions]::Configure($pipelineBuilder, [string]::Join('+', $advancedMarkdownExtensions))
        Write-verbose "Building Markdig pipeline"
        $pipeline = $pipelineBuilder.Build()
        ##>
    
    ##    // Configure the pipeline with all advanced extensions active
    [Markdig.MarkdownPipelineBuilder]$pipelineBuilder = (New-Object Markdig.MarkdownPipelineBuilder)
    $pipeline = [Markdig.MarkDownExtensions]::UseAdvancedExtensions($pipelineBuilder)
    $pipeline = $pipelineBuilder.Build()
    ##>
    <#
    $pipelineBuilder = [Markdig.MarkdownPipelineBuilder]::new()
    $pipeline = [Markdig.MarkDownExtensions]::UseAdvancedExtensions($pipelineBuilder)
    $pipeline = $pipelineBuilder.Build()
    ##>
    #endregion Initialize
    
    #region setup
    # Get the command name
    $CommandName = $PSCmdlet.MyInvocation.InvocationName;
    # Get the list of parameters for the command
    "${CommandName}: Input", (((Get-Command -Name ($PSCmdlet.MyInvocation.InvocationName)).Parameters) |
      ForEach-Object { Get-Variable -Name $_.Values.Name -ErrorAction SilentlyContinue; } |
      Format-Table -AutoSize @{ Label = "Name"; Expression = { $_.Name }; }, @{ Label = "Value"; Expression = { (Get-Variable -Name $_.Name -EA SilentlyContinue).Value }; }) |
    Out-String | write-verbose
    #endregion
  }
  Process
  {
    #for each Markdown file
    # 1. Use MarkDig to convert the markdown to the HTML body
    # 2. Adding the CSS and in the header
    # 3. Create the file
    
    foreach ($mdfile in $Path)
    {
      $ext = [system.io.path]::GetExtension($mdfile.fullname)
      if ($ext -in @(".md",".markdown"))
      {
        $htmlFileName = [system.io.path]::ChangeExtension($mdfile.fullname, "html")
        $Name = [system.io.path]::GetFileNameWithoutExtension($mdfile.fullname)
        $cmdline = ('{0} ==> {1}' -f $mdfile.fullname, $htmlFileName)
        if ($PSCmdlet.ShouldProcess(
            "$cmdline",
            "Convert-Markdown"))
        {
          #Write-Verbose $($file + " ==> " + $htmlFileName)
          $sb = New-Object System.Text.StringBuilder
          [void]$sb.AppendLine('<!doctype html>')
          [void]$sb.AppendLine('<html>')
          [void]$sb.AppendLine("<head>")
          [void]$sb.AppendLine('<meta charset="utf-8">')
          [void]$sb.AppendLine('<meta http-equiv="x-ua-compatible" content="ie=edge">')
          [void]$sb.AppendLine('<meta http-equiv="expires" content="0"> <!-- Never caches the page -->')
          [void]$sb.AppendLine('<link rel="shortcut icon" type="image/jpg" href="favicon.png"/>')
          [void]$sb.AppendLine("<title>$Name</title>")
          if ($CssPath)
          {
            [void]$sb.Append('<style type="text/css">')
            if (Test-Path $CssPath) { [void]$sb.Append((get-content $CssPath)) }
            [void]$sb.AppendLine('</style>')
          }
          if ($HighlightCssPath -and $HighlightJsPath)
          {
            [void]$sb.Append('<style type="text/css">')
            [void]$sb.Append((get-content $HighlightCssPath)) 
            [void]$sb.AppendLine('</style>')
            [void]$sb.AppendLine($('<script src="{0}"></script>' -f $HighlightJsPath))
            [void]$sb.AppendLine('<script>')
            [void]$sb.AppendLine('hljs.configure({ languages: [] });')
            [void]$sb.AppendLine('hljs.initHighlightingOnLoad();')
            [void]$sb.AppendLine('</script> ')
          }
          [void]$sb.AppendLine('</head>')
          [void]$sb.AppendLine('<body>')
          try
          {
            if ($mdfile.Length -gt 0)
            {
              [void]$sb.AppendLine($([Markdig.Markdown]::ToHtml($(Get-Content -Raw $mdfile.fullname), $pipeline)))
            }
          }
          catch [ArgumentNullException] {
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
}

