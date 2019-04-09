<#
.SYNOPSIS

This is a psake script

Builds a deliverable versioned zip file

.DESCRIPTION

The Project Name is the current directory name

 $ProjectName = [System.IO.Path]::GetFileName($PSScriptRoot)


#>
#region initialisation
Framework '4.0'
Set-StrictMode -Version 4
$me = $MyInvocation.MyCommand.Definition
filter Skip-Empty { $_ | Where-Object { $_ -ne $null -and $_ } }
$IsVerbose = $false
$PSBoundParameters | Out-String | Write-Verbose -verbose:$IsVerbose

Import-Module "$PSScriptRoot\md2html"
Import-Module Ruusty.ReleaseUtilities -verbose:$IsVerbose

function Get-SettingFromXML {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            Position = 0)]
        [system.Xml.XmlDocument]$Xmldoc,
        [Parameter(Mandatory = $true,
            Position = 1)]
        [string]$xpath
    )
    Write-Debug $('Getting value from xpath : {0}' -f $xpath)
    try {
        $Xmldoc.SelectNodes($xpath).value
    }
    # Catch specific types of exceptions thrown by one of those commands
    catch [System.Exception] {
        Write-Error -Exception $_.Exception
    }
    # Catch all other exceptions thrown by one of those commands
    catch {
        Throw "XML error"
    }
}
FormatTaskName "`r`n[------{0}------]`r`n"
Properties {
    $script:config_vars = @()
    # Add variable names to $config_vars to display their values
    $script:config_vars += @(
        "GlobalPropertiesName"
        , "GlobalPropertiesPath"
        , "GitExe"
        , "CoreDeliveryDirectory"
        , "CoreReleaseStartDate"
        , "ProjectName"
        , "ProjTopdir"
        , "ProjBuildPath"
        , "ProjDistPath"
        , "ProjPackageListPath"
        , "ProjPackageZipPath"
        , "ProjHistoryPath"
        , "ProjVersionPath"
        , "ProjModulePath" 
        , "ProjHistorySinceDate"
        , "ProjDeliveryPath"
        , "ProjPackageZipVersionPath"
        , "CoreMajorMinor"
        , "CoreChocoFeed"
        , "sdlc"
        , "IsVerbose"
    )
    $IsVerbose              = ($VerbosePreference -eq 'Continue')
    $whatif = $false;
    $now = [System.DateTime]::Now
    $Branch = & { git.exe symbolic-ref --short HEAD }
    $isMaster = if ($Branch -eq 'master') { $true } else { $false }
    Write-Verbose($("CurrentLocation={0}" -f $executionContext.SessionState.Path.CurrentLocation))
    $GlobalPropertiesName = $("GisOms.Chocolatey.properties.{0}.xml" -f $env:COMPUTERNAME)
    $GlobalPropertiesPath = Ruusty.ReleaseUtilities\Find-FileUp $GlobalPropertiesName
  
    $GlobalPropertiesXML = New-Object XML
    $GlobalPropertiesXML.Load($GlobalPropertiesPath)
  
    $GitExe = Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='git.exe']"
    $7zipExe = Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='tools.7zip']"
    $ChocoExe = Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='tools.choco']"  
    $CoreDeliveryDirectory = Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='core.delivery.dir']" 
    $CoreReleaseStartDate = Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='GisOms.release.StartDate']"  
    $CoreChocoFeed =        Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='core.delivery.chocoFeed.dir']"
    $SpatialGitHubPath =    Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='Spatial_GitHub.Path']"
    $CoreMajorMinor = Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='GisOms.release.MajorMinor']"

    $ProjectName = [System.IO.Path]::GetFileName($PSScriptRoot)
    $ProjTopdir = $PSScriptRoot
    $ProjBuildPath = Join-Path $ProjTopdir "Build"
    $ProjDistPath = Join-Path $ProjTopdir "Dist"
    $ProjPackageListPath = Join-Path $ProjTopdir "${ProjectName}.lis"
    $ProjPackageZipPath = Join-Path $ProjDistPath  "${ProjectName}.zip"
    $ProjDeliveryPath = Join-Path $(Join-Path $CoreDeliveryDirectory ${ProjectName})  '${versionNum}'
    $ProjPackageZipVersionPath = Join-Path $ProjDeliveryPath  '${ProjectName}.${versionNum}.zip'
  
    $ProjBuildDateTime = $now.ToString("yyyy-MM-ddTHH-mm")
    $ProjVersionPath = Join-Path $ProjTopdir   "${ProjectName}.Build.Number"
    $ProjModulePath = Join-Path $ProjBuildPath "md2html"
    $ProjHistoryPath = Join-Path $ProjModulePath  "${ProjectName}.history.txt"
  
    $ProjHistorySinceDate = "2015-05-01"
    $ProjNuspecPath = Join-Path $ProjTopdir "${ProjectName}.nuspec"
    $ProjNuspecPkgVersionPath = Join-Path $ProjDistPath  '${ProjectName}.${versionNum}.nupkg'

    Set-Variable -Name "sdlc" -Description "System Development Lifecycle Environment" -Value "UNKNOWN"
    $zipArgs = 'a -bb2 -tzip "{0}" -ir0@"{1}"' -f $ProjPackageZipPath, $ProjPackageListPath # Get paths from file
    #$zipArgs = 'a -bb2 -tzip "{0}" -ir0!*' -f $ProjPackageZipPath #Everything in $ProjBuildPath
  
    Write-Host "Verbose: $IsVerbose"
    Write-Verbose "Verbose"
  
}

Task default -depends build
Task test-build -depends Show-Settings,     clean-Dry-Run, unit-test, set-version, compile, compile-nupkg
Task build      -depends Show-Settings, git-status, clean, unit-test, set-version, compile, compile-nupkg, tag-version, distribute


Task  show-deliverable {
    $versionNum = Get-Content $ProjVersionPath
    $nupkg = $([System.IO.Path]::GetFileName($ExecutionContext.InvokeCommand.ExpandString($ProjNuspecPkgVersionPath)))
    $ExpArgs = "/e,/root,${CoreChocoFeed}/select,`"$CoreChocoFeed\$nupkg`""
    $ExpArgs = "/e,/root,${CoreChocoFeed}"
    Write-Host $("explorer.exe {0}" -f $ExpArgs)
  
    & cmd.exe /c explorer.exe $CoreChocoFeed
    #& cmd.exe /c explorer.exe $ExpArgs
}

Task clean-dirs {
    if ((Test-Path $ProjBuildPath)) { Remove-Item $ProjBuildPath -Recurse -force }
    if ((Test-Path $ProjDistPath)) { Remove-Item $ProjDistPath -Recurse -force }
}

Task create-dirs {
    if (!(Test-Path $ProjBuildPath)) { mkdir -Path $ProjBuildPath }
    if (!(Test-Path $ProjDistPath)) { mkdir -Path $ProjDistPath }
}

Task compile -description "Build Deliverable zip file" -depends clean, create-dirs {
    $versionNum = Get-Content $ProjVersionPath
    $version = [system.Version]::Parse($versionNum)

    $copyArgs = @{
        path        = @(
            "$ProjTopdir\md2html"
        )
        exclude     = @("*.log", "*.html", "*.credential", "*.TempPoint.psd1", "*.TempPoint.ps1", "*.Tests.ps1", "*.psproj", "*.psprojs", "Test-Module.ps1","Specification/**")
        destination = $ProjBuildPath 
        recurse     = $true
    }
    Write-Host "Attempting to get deliverables"
    Copy-Item @copyArgs -verbose:$IsVerbose
  
    Write-Host "Attempting to get Git History"
    Exec { & $GitExe "log"  --since="$ProjHistorySinceDate" --pretty=format:"%h - %an, %ai : %s" } | Set-Content $ProjHistoryPath
  
    Write-Host "Attempting Versioning README.md"
    Ruusty.ReleaseUtilities\Set-VersionReadme "$ProjBuildPath/md2html/README.md"  $version  $now
  
    Write-Host "Attempting Versioning md2html.psd1 "
    Ruusty.ReleaseUtilities\Set-VersionModule "$ProjBuildPath/md2html/md2html.psd1"  $version
  
    Write-Host "Attempting convert markdown to html"
    Convert-Markdown2Html  -path "$ProjBuildPath\*.md" -verbose:$IsVerbose -recurse
  
    Write-Host "Attempting to create zip file with '$zipArgs'"
    Ruusty.ReleaseUtilities\Start-Exe -FilePath $7zipExe -ArgumentList $zipArgs -workingdirectory $ProjBuildPath
  
    Copy-Item "$ProjBuildPath/README.*" $ProjDistPath
  
}

Task compile-nupkg -description "Compile Chocolatey nupkg from nuspec" {
    $versionNum = Get-Content $ProjVersionPath
    Write-Host $("Compiling {0}" -f $ProjNuspecPath)
    Exec { & $ChocoExe pack $ProjNuspecPath --version $versionNum --output-directory $ProjDistPath }
}

Task distribute -description "Push nupkg to Chocolatey Feed" -PreCondition { $isMaster } {
    $versionNum = Get-Content $ProjVersionPath
    $nupkg = $ExecutionContext.InvokeCommand.ExpandString($ProjNuspecPkgVersionPath)
    Write-Host $("Pushing {0}" -f $nupkg)
    Exec { & $ChocoExe  push $nupkg -s $CoreChocoFeed }
}


Task clean -description "Remove generated files" -depends clean-dirs {
    Exec { & $GitExe "ls-files" --others --exclude-standard | ForEach-Object { Remove-Item $_ -verbose:$IsVerbose } }
}


Task clean-Dry-Run -description "Remove generated files" -depends clean-dirs {
    Exec { & $GitExe "ls-files" --others --exclude-standard | ForEach-Object { Remove-Item $_ -confirm -verbose:$IsVerbose } }
}

Task set-version -description "Create the file containing the version" -depends create-dirs {
    $version = Ruusty.ReleaseUtilities\Get-Version -Major $($CoreMajorMinor.split('.')[0]) -Minor $($CoreMajorMinor.split('.')[1])
    Set-Content $ProjVersionPath $version.ToString()
    Write-Host $("Version:{0}" -f $(Get-Content $ProjVersionPath))
}

Task tag-version -description "Create a tag with the version number" -PreCondition { $isMaster } {
    $versionNum = Get-Content $ProjVersionPath
    Exec { & $GitExe "tag" "V$versionNum" }
}

Task get-version -description "Display the version" {
    $versionNum = Get-Content $ProjVersionPath
    Write-Host $("Version:{0}" -f $versionNum)
}

Task git-revision -description "" {
    Exec { & $GitExe "describe" --tag }
}

Task git-history -description "Create git history file" -depends create-dirs {
    Exec { & $GitExe "log"  --since="$ProjHistorySinceDate" --pretty=format:"%h - %an, %ai : %s" } | Set-Content $ProjHistoryPath
}

Task git-status -description "Stop the build if there are any uncommitted changes" {
    $rv = Exec { & $GitExe status --short  --porcelain }
    $rv | Write-Host
  
    #Extras
    #exec { & git.exe ls-files --others --exclude-standard }
  
    if ($rv) {
        throw $("Found {0} uncommitted changes" -f ([array]$rv).Count)
    }
}


Task Show-Settings -description "Display the psake configuration properties variables" {
    Write-Verbose("Verbose is on")
    Get-Variable -name $script:config_vars -ea SilentlyContinue | Sort-Object -Property name -CaseSensitive | Format-Table -property name, value -autosize | Out-String -Width 2000 | Out-Host
    #Get-Variable -name $script:config_vars -ea SilentlyContinue | Sort-Object -Property name -CaseSensitive | Format-List -Expand CoreOnly -property name, value | Out-String -Width 2000 | Out-Host
}

Task unit-test {
    Push-Location "$PSScriptRoot/md2html/Specification"
    get-location | write-verbose -verbose:$IsVerbose
    $testResults = Invoke-Pester -Script @{Path = "*.Tests.ps1"; Parameters = @{Verbose = $isVerbose; } }  -PassThru 
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
        #Write-Error -exception $e -Message $("{0} process.ExitCode {1}" -f $FilePath, $rc) -TargetObject $FilePath -category "InvalidResult"
    }
    pop-location
}


Task ? -Description "Helper to display task info" -depends help {
}


Task help -Description "Helper to display task info" {
    Invoke-psake -buildfile $me -detaileddocs -nologo
    Invoke-psake -buildfile $me -docs -nologo
}