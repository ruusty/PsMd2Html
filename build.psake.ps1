<#
.SYNOPSIS

This is a psake script

Builds a deliverable versioned zip file

.DESCRIPTION

The Project Name is the current directory name

 $ProjectName = [System.IO.Path]::GetFileName($PSScriptRoot)


#>
Framework '4.0'
Set-StrictMode -Version 4
$me = $MyInvocation.MyCommand.Definition
filter Skip-Empty { $_ | ?{ $_ -ne $null -and $_ } }


Import-Module "$PSScriptRoot\md2html"
Import-Module Ruusty.ReleaseUtilities -verbose

FormatTaskName "`r`n[------{0}------]`r`n"
properties {
  $script:config_vars = @()
  # Add variable names to $config_vars to display their values
  $script:config_vars += @(
    "GlobalPropertiesName"
     ,"GlobalPropertiesPath"
     ,"GitExe"
     ,"CoreDeliveryDirectory"
     ,"CoreReleaseStartDate"
     ,"ProjectName"
     ,"ProjTopdir"
     ,"ProjBuildPath"
     ,"ProjDistPath"
     ,"ProjPackageListPath"
     ,"ProjPackageZipPath"
     ,"ProjHistoryPath"
     ,"ProjVersionPath"
     ,"ProjModulePath" 
     ,"ProjHistorySinceDate"
     ,"ProjDeliveryPath"
     ,"ProjPackageZipVersionPath"
     ,"CoreMajorMinor"
     ,"CoreChocoFeed"
     ,"sdlc"
  )
  $verbose = $true;
  $whatif = $false;
  $now = [System.DateTime]::Now
  $Branch = & { git symbolic-ref --short HEAD }
  $isMaster = if ($Branch -eq 'master') { $true } else { $false }
  write-verbose($("CurrentLocation={0}" -f $executionContext.SessionState.Path.CurrentLocation))
  $GlobalPropertiesName = $("GisOms.Chocolatey.properties.{0}.xml" -f $env:COMPUTERNAME)
  $GlobalPropertiesPath = Ruusty.ReleaseUtilities\Find-FileUp $GlobalPropertiesName
  
  $GlobalPropertiesXML = New-Object XML
  $GlobalPropertiesXML.Load($GlobalPropertiesPath)
  
  $GitExe = $GlobalPropertiesXML.SelectNodes("/project/property[@name='git.exe']").value
  $zipExe = $GlobalPropertiesXML.SelectNodes("/project/property[@name='tools.7zip']").value
  $ChocoExe = $GlobalPropertiesXML.SelectNodes("/project/property[@name='tools.choco']").value
  
  $CoreDeliveryDirectory = $GlobalPropertiesXML.SelectNodes("/project/property[@name='core.delivery.dir']").value
  #$CoreDeliveryDirectory = Join-Path $CoreDeliveryDirectory "GisOms"#todo Change to suite needs
  $CoreReleaseStartDate = $GlobalPropertiesXML.SelectNodes("/project/property[@name='GisOms.release.StartDate']").value
  $CoreMajorMinor = $GlobalPropertiesXML.SelectNodes("/project/property[@name='GisOms.release.MajorMinor']").value
  $CoreChocoFeed = $GlobalPropertiesXML.SelectNodes("/project/property[@name='core.delivery.chocoFeed.dir']").value
  
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
  
  Write-Host "Verbose: $verbose"
  Write-Verbose "Verbose"
  
}

task default -depends build
task test-build -depends Show-Settings,             clean, unit-test, set-version, compile, compile-nupkg
task build      -depends Show-Settings, git-status, clean, unit-test, set-version, compile, compile-nupkg, tag-version, distribute


task  show-deliverable {
  $versionNum = Get-Content $ProjVersionPath
  $nupkg = $([System.IO.Path]::GetFileName($ExecutionContext.InvokeCommand.ExpandString($ProjNuspecPkgVersionPath)))
  $ExpArgs = "/e,/root,${CoreChocoFeed}/select,`"$CoreChocoFeed\$nupkg`""
  $ExpArgs = "/e,/root,${CoreChocoFeed}"
  Write-Host $("explorer.exe {0}" -f $ExpArgs)
  
  & cmd.exe /c explorer.exe $CoreChocoFeed
  #& cmd.exe /c explorer.exe $ExpArgs
}

task clean-dirs {
  if ((Test-Path $ProjBuildPath)) { Remove-Item $ProjBuildPath -Recurse -force }
  if ((Test-Path $ProjDistPath)) { Remove-Item $ProjDistPath -Recurse -force }
}

task create-dirs {
  if (!(Test-Path $ProjBuildPath)) { mkdir -Path $ProjBuildPath }
  if (!(Test-Path $ProjDistPath)) { mkdir -Path $ProjDistPath }
}

task compile -description "Build Deliverable zip file" -depends clean, create-dirs {
  $versionNum = Get-Content $ProjVersionPath
  $version = [system.Version]::Parse($versionNum)

  $copyArgs = @{
    path  = @(
      "$ProjTopdir\md2html"
    )
    exclude = @("*.log", "*.html", "*.credential", "*.TempPoint.psd1", "*.TempPoint.ps1", "*.Tests.ps1", "*.psproj", "*.psprojs", "Test-Module.ps1")
    destination = $ProjBuildPath 
    recurse = $true
  }
  Write-Host "Attempting to get deliverables"
  Copy-Item @copyArgs -verbose:$verbose
  
  Write-Host "Attempting to get Git History"
  exec { & $GitExe "log"  --since="$ProjHistorySinceDate" --pretty=format:"%h - %an, %ai : %s" } | Set-Content $ProjHistoryPath
  
  Write-Host "Attempting Versioning README.md"
  Ruusty.ReleaseUtilities\Set-VersionReadme "$ProjBuildPath/md2html/README.md"  $version  $now
  
  Write-Host "Attempting Versioning md2html.psd1 "
  Ruusty.ReleaseUtilities\Set-VersionModule "$ProjBuildPath/md2html/md2html.psd1"  $version
  
  Write-Host "Attempting convert markdown to html"
  Convert-Markdown2Html  -path "$ProjBuildPath\*.md" -verbose:$verbose -recurse
  
  Write-Host "Attempting to create zip file with '$zipArgs'"
  Ruusty.ReleaseUtilities\Start-exe -FilePath $zipExe -ArgumentList $zipArgs -workingdirectory $ProjBuildPath
  
  Copy-Item "$ProjBuildPath/README.*" $ProjDistPath
  
}

task compile-nupkg -description "Compile Chocolatey nupkg from nuspec" {
  $versionNum = Get-Content $ProjVersionPath
  Write-Host $("Compiling {0}" -f $ProjNuspecPath)
  exec { & $ChocoExe pack $ProjNuspecPath --version $versionNum --output-directory $ProjDistPath }
}

task distribute -description "Push nupkg to Chocolatey Feed" -PreCondition { $isMaster } {
  $versionNum = Get-Content $ProjVersionPath
  $nupkg = $ExecutionContext.InvokeCommand.ExpandString($ProjNuspecPkgVersionPath)
  Write-Host $("Pushing {0}" -f $nupkg)
  exec { & $ChocoExe  push $nupkg -s $CoreChocoFeed }
}

task clean -description "Remove generated files" -depends clean-dirs

task set-version -description "Create the file containing the version" -depends create-dirs {
  $version = Ruusty.ReleaseUtilities\Get-Version -Major $($CoreMajorMinor.split('.')[0]) -Minor $($CoreMajorMinor.split('.')[1])
  Set-Content $ProjVersionPath $version.ToString()
  Write-Host $("Version:{0}" -f $(Get-Content $ProjVersionPath))
}

task tag-version -description "Create a tag with the version number" -PreCondition { $isMaster }  {
  $versionNum = Get-Content $ProjVersionPath
  exec { & $GitExe "tag" "V$versionNum" }
}

task get-version -description "Display the version" {
  $versionNum = Get-Content $ProjVersionPath
  Write-Host $("Version:{0}" -f $versionNum)
}

task git-revision -description "" {
  exec { & $GitExe "describe" --tag }
}

task git-history -description "Create git history file" -depends create-dirs {
  exec { & $GitExe "log"  --since="$ProjHistorySinceDate" --pretty=format:"%h - %an, %ai : %s" } | Set-Content $ProjHistoryPath
}

task git-status -description "Stop the build if there are any uncommitted changes" {
  $rv = exec { & $GitExe status --short  --porcelain }
  $rv | write-host
  
  #Extras
  #exec { & git.exe ls-files --others --exclude-standard }
  
  if ($rv)
  {
    throw $("Found {0} uncommitted changes" -f ([array]$rv).Count)
  }
}



task Show-Settings -description "Display the psake configuration properties variables"   {
  Write-Verbose("Verbose is on")
  Get-Variable -name $script:config_vars -ea Continue | sort -Property name -CaseSensitive | Format-Table -property name, value -autosize | Out-String -Width 2000 | Out-Host
  Get-Variable -name $script:config_vars -ea Continue | sort -Property name -CaseSensitive | format-list -Expand CoreOnly -property name, value | Out-String -Width 2000 | Out-Host
}

task unit-test {
  $FilePath = "$PSScriptRoot/Specification/Pester.Tests.md2html.bat"
  & $FilePath
  #write-Host "`$LastExitCode=$LastExitCode`r`n"
  $rc = $LastExitCode
  if ($rc -ne 0)
  {
    & "$Env:SystemRoot\system32\cmd.exe" /c exit $rc
    $e = [System.Management.Automation.RuntimeException]$("{0} ExitCode:{1}" -f $FilePath, $rc)
    Write-Error -exception $e -Message $("{0} process.ExitCode {1}" -f $FilePath, $rc) -TargetObject $FilePath -category "InvalidResult"
  }
  
}


task ? -Description "Helper to display task info" -depends help {
}


task help -Description "Helper to display task info" {
  Invoke-psake -buildfile $me -detaileddocs -nologo
  Invoke-psake -buildfile $me -docs -nologo
}