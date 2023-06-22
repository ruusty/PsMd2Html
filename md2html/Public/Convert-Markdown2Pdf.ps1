<#
    .SYNOPSIS
        Convert Markdown files to pdf

    .DESCRIPTION
        Convert Markdown files to html then to pdf using wkhtmltopdf.exe
        from Markdown Monster

    .PARAMETER Path
        Wildcard filespec of Markdown files

    .PARAMETER Recurse
    Recurse directories for Markdown files using Path

    .PARAMETER wkhtmltopdf
        Path to wkhtmltopdf executable

    .PARAMETER WkhtmltopdfArgumentList
        Arguments passed to wkhtmltopdf executable

    .EXAMPLE
        convert-Markdown2pdf -path *.md

        Markdown files in the current directory

    .EXAMPLE
    Convert-Markdown2pdf -Path *.md -recurse -whatif

    Markdown files in the current directory and subdirectories

#>
function Convert-Markdown2Pdf {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (    
        [Parameter(Position = 1)]
        [string]$Path = "*.md"
       ,[switch]$Recurse
       ,[string]$wkhtmltopdf = "C:\Users\Russell\AppData\Local\Markdown Monster\BinSupport\wkhtmltopdf.exe" 
       ,[Alias('ArgList')]
        [String[]] $WkhtmltopdfArgumentList = (
            "--enable-local-file-access",
            "--image-dpi 300", 
            "--page-size A4", 
            "--orientation Portrait",
            "--enable-internal-links", 
            "--keep-relative-links",
            "--print-media-type" ,
            "--encoding UTF-8",
            "--footer-font-size 0",
            '--footer-right "Page [page] of [topage]"'  )
    )
    Begin {
        if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
            $VerbosePreference = 'Continue'
        }
        if ($PSCmdlet.MyInvocation.BoundParameters["Whatif"].IsPresent) {
            write-host "WhatIf On"
        }
        
        $IsVerbose = ($VerbosePreference -eq 'Continue')
        #region setup
        # Get the command name
        $CommandName = $PSCmdlet.MyInvocation.InvocationName;
        # Get the list of parameters for the command
        "${CommandName}: Input", (((Get-Command -Name ($PSCmdlet.MyInvocation.InvocationName)).Parameters) |
            ForEach-Object { Get-Variable -Name $_.Values.Name -ErrorAction SilentlyContinue; } |
            Format-Table -AutoSize @{ Label = "Name"; Expression = { $_.Name }; }, @{ Label = "Value"; Expression = { (Get-Variable -Name $_.Name -EA SilentlyContinue).Value }; }) |  Out-String | write-verbose
        #endregion
        Write-Verbose $('{0}=={1}' -f '$PSScriptRoot', $PSScriptRoot)
    }
    Process {
        $GetChildItemArgs = @{ Path = $Path };
        if ($Recurse) {
            $GetChildItemArgs += @{ recurse = $Recurse }
        }
        Convert-Markdown2Html @GetChildItemArgs  -Verbose:$IsVerbose -WhatIf:$WhatIfPreference
        Get-ChildItem @GetChildItemArgs -File -Exclude "*.html" | Sort-Object -unique 
        | ForEach-Object {
            if ($([system.io.path]::GetExtension($_.FullName)) -in @(".md", ".markdown")) {
            $htmlPath = [System.IO.path]::ChangeExtension($_.FullName, "html")
            $pdfPath  = [System.IO.path]::ChangeExtension($_.FullName, "pdf")
            write-verbose $("{0}==>{1}" -f $htmlPath, $pdfPath)
            try {
                if ($PSCmdlet.ShouldProcess(
                        $($WkhtmltopdfArgumentList + ($htmlPath, $pdfPath)),
                        "$wkhtmltopdf")) {
                    Start-Process -FilePath "$wkhtmltopdf" -ArgumentList $($($WkhtmltopdfArgumentList -join ' ' ) + $(' "{0}" "{1}"' -f ($htmlPath, $pdfPath))) -Verbose:$IsVerbose  -wait
                    $pdfFile = (Get-ChildItem -Path $pdfPath)
                    $htmlFile = (Get-ChildItem -Path $htmlPath)
                    $pdfFile.lastwritetime = $htmlFile.lastwritetime
                    $pdfFile.CreationTime = $htmlFile.CreationTime
                }
            }
            catch {
                write-Error $_
            }
            finally {
                Start-Sleep -Milliseconds 100;
            }
           } 
        }  
    }
}
