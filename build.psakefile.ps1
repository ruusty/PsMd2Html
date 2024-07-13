<#
.SYNOPSIS
  This is a psake script

.DESCRIPTION
  Build a deliveable and packaging with Chocolatey.
  The Project Name is the current directory name

#>
#region initialisation
Framework '4.0'
Set-StrictMode -Version 4
$me = $MyInvocation.MyCommand.Definition
filter Skip-Empty { $_ | Where-Object { $_ -ne $null -and $_ } }

FormatTaskName "`r`n[------{0}------]`r`n"
$IsVerbose              = ($VerbosePreference -eq 'Continue')
$PSBoundParameters | Out-String | Write-Verbose -verbose:$IsVerbose


import-module -RequiredVersion 4.6.0 pester
Import-Module Ruusty.ReleaseUtilities -verbose:$IsVerbose

<#
  .SYNOPSIS
    Get a setting from xml

  .DESCRIPTION
    Get a setting from xml

#>
function Get-SettingFromXML
{
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
  write-debug $('Getting value from xpath : {0}' -f $xpath)
  try
  {
    $Xmldoc.SelectNodes($xpath).value
  }
  # Catch specific types of exceptions thrown by one of those commands
  catch [System.Exception] {
    Write-Error -Exception $_.Exception
  }
  # Catch all other exceptions thrown by one of those commands
  catch
  {
    Throw "XML error"
  }
}

Properties {
  Write-Verbose "Verbose is ON"
  Write-Host $('{0} ==> {1}' -f '$VerbosePreference', $VerbosePreference)
  Write-Host $('{0} ==> {1}' -f '$DebugPreference', $DebugPreference)

  $script:config_vars = @()
  # Add variable names to $config_vars to display their values
  $script:config_vars += @(
      "GlobalPropertiesName"
     ,"GlobalPropertiesPath"
  )
  $whatif = $false;
  $now = [System.DateTime]::Now
  $Branch = & { git symbolic-ref --short HEAD }
  $isMaster = if ($Branch -in ('main','master') ) {$true} else {$false}
  write-debug($("CurrentLocation={0}" -f $executionContext.SessionState.Path.CurrentLocation))
  $GlobalPropertiesName=$("Ruusty.Chocolatey.properties.{0}.xml" -f $env:COMPUTERNAME)
  $GlobalPropertiesPath = Ruusty.ReleaseUtilities\Find-FileUp "Ruusty.Chocolatey.properties.${env:COMPUTERNAME}.xml" -verbose
  Write-Host $('$GlobalPropertiesPath:{0}' -f $GlobalPropertiesPath)
  $GlobalPropertiesXML = New-Object XML
  $GlobalPropertiesXML.Load($GlobalPropertiesPath)
  $script:config_vars += @(
  "whatif"
  ,"now"
  ,"Branch"
  ,"isMaster"
    )

  $GitExe =                 Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='git.exe']"
  $7zipExe =                Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='tools.7zip']"
  $ProjMajorMinor =         Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='Ruusty.release.MajorMinor']"
  $CoreDeliveryDirectory =  Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='core.delivery.dir']"
  $CoreReleaseStartDate =   Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='Ruusty.release.StartDate']"
  $ChocoExe =               Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='tools.choco']"
  $CoreChocoFeed =          Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='core.delivery.chocoFeed.dir']"
  $ProjHistorySinceDate =   Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='Ruusty.history.AfterDate']"
  $ProjDeliveryPath     =   Get-SettingFromXML -xmldoc $GlobalPropertiesXML -xpath "/project/property[@name='core.delivery.chocoFeed.dir']"

  $script:config_vars += @(
  ,"GitExe"
  ,"7zipExe"
  ,"ChocoExe"
  ,"ProjMajorMinor"
  ,"CoreDeliveryDirectory"
  ,"CoreChocoFeed"
  ,"CoreReleaseStartDate"
  )

  $ProjTopdir = $PSScriptRoot
  $ProjBuildPath = Join-Path $ProjTopdir "Build"
  $ProjDistPath = Join-Path $ProjTopdir "Dist"
  $ProjToolsPath = Join-Path $ProjTopdir "Tools"
  $script:config_vars += @(
      "ProjectName"
     ,"ProjTopdir"
     ,"ProjBuildPath"
     ,"ProjDistPath"
     ,"ProjToolsPath"
  )

  $NuspecPath = $(Get-ChildItem -path "$PSScriptRoot/*.nuspec")[0].fullname
  $NuspecPropertiesXML = New-Object XML
  $NuspecPropertiesXML.Load($NuspecPath)

  $ProjectName = $NuspecPropertiesXML.package.metadata.title
  $ProjectId   = $NuspecPropertiesXML.package.metadata.id

  
  $ProjPackageListPath = Join-Path $ProjTopdir "${ProjectName}.lis"
  $ProjPackageZipPath = Join-Path $ProjDistPath "${ProjectName}.zip"
  $zipArgs = 'a -bb2 -tzip "{0}" -ir0@"{1}"' -f $ProjPackageZipPath, $ProjPackageListPath # Get paths from file
  
  $script:config_vars += @(
      "ProjPackageListPath"
     ,"ProjPackageZipPath"
     ,"zipArgs"
  )
  
  
  
  $ProjHistoryPath = Join-Path $ProjTopdir "${ProjectName}.git_history.txt"
  $ProjVersionPath = Join-Path $ProjTopdir "${ProjectName}.Build.Number"
  $ProjReadmePath   = Join-Path $ProjTopdir "README.md"
  $ProjNuspecName = "${ProjectName}"
  $ProjNuspec = "${ProjNuspecName}.nuspec"
  $ProjNuspecPath = Join-Path $ProjTopdir "${ProjNuspecName}.nuspec"
  $ProjNuspecPkgVersionPath = Join-Path $ProjTopdir  '${ProjNuspecName}.${versionNum}.nupkg'



  $script:config_vars += @(
    "ProjHistoryPath"
     ,"ProjVersionPath"
     ,"ProjNuspecName"
     ,"ProjNuspecPath"
     ,"ProjNuspecPkgVersionPath"
     ,"ProjHistorySinceDate"
     #,"ProjPackageZipVersionPath"
     ,"ProjNuspec"
     ,"ProjReadmePath"
    , "ProjDeliveryPath"
  )
  
  Set-Variable -Name "sdlc" -Description "System Development Lifecycle Environment" -Value "UNKNOWN"
  $sdlcs = @('prod', 'uat','test','dev') #nupkg specific to a SDLC
  $sdlcs = @('ALL')                      #nupkg does all SDLCs
    $script:config_vars += @(
     ,"sdlc"
    ,"sdlcs"
  )

  <# Robocopy settings #>
  <# Tweek exDir exFile to define files to include in zip #>
  $exDir = @("$ProjTopdir\RuustyTools\.TEMPLATE", "Build", "Dist", "tools", ".git", "specs", "Specification", "wrk", "work")
  $exFile = @("build.bat", "build.psake.ps1", "*.nuspec", ".gitignore", "*.config.ps1", "*.lis", "*.nupkg", "*.Tests.ps1", "*.html", "*Pester*", "*.Tests.Setup.ps1")


  <# Custom additions #>
  #$exDir += @( ".Archive", ".SlickEdit")
  #$exFile +=  @( "*.build", "*.tt", "*(Original)*.*", "*.credential", "*.ttinclude", ".dir", "*.TempPoint.*")
  <# Customer additions #>


  #Quote the elements
  $XD = ($exDir | %{ "`"$_`"" }) -join " "
  $XF = ($exFile | %{ "`"$_`"" }) -join " "

  # Quote the RoboCopy Source and Target folders
  $RoboSrc = '"{0}\md2html"' -f $ProjTopdir
  $RoboTarget = '"{0}\md2html"' -f $ProjBuildPath
  $script:config_vars += @(
     "exDir"
    ,"exFile"
    ,"XD"
    ,"XF"
    ,"RoboSrc"
    ,"RoboTarget"
  )

  Write-Verbose "Verbose is ON"
  Write-Host $('{0} ==> {1}' -f '$VerbosePreference', $VerbosePreference)

}

Task default -depends build
Task test-build -depends Show-Settings,      clean-DryRun, unit-test, set-version, compile, compile-nupkg
Task build      -depends Show-Settings, git-status, clean, unit-test, set-version, compile, compile-nupkg, tag-version, distribute



task Compile -description "Build Deliverable zip file" -depends create-dirs, set-version   {
  $versionNum = Get-Content $ProjVersionPath
  $version = [system.Version]::Parse($versionNum)

  Write-Verbose "Verbose is on"
  Write-Host "Attempting to get source files"

  $RoboArgs = @($RoboSrc, $RoboTarget, '/S', '/XD', $XD, '/XF', $XF)
  Write-Host $('Robocopy.exe {0}' -f ($RoboArgs -join " "))
  #start-exe captures robocopy stderr
  try
  {
    Ruusty.ReleaseUtilities\start-exe "Robocopy.exe" -ArgumentList $RoboArgs #-workingdirectory $ProjBuildPath

  }
  catch [Exception] {
    $ex = $_
    $innerEx = $ex.Exception
#   In an exception but LastExitCode is 0 Need to check the ErrorRecord String

<#        $ex  | Get-Member

    write-Host $("Robocopy.exe LastExitCode={0}`r`n" -f $LastExitCode)
    $errMsg1 = $ex | Format-List * -Force | Out-String
    Write-host $("{0}==>{1}<==`n" -f "Exception", $errMsg1)
    Write-host  $("{0}==>{1}<==`n" -f "FullyQualifiedErrorId", $ex.FullyQualifiedErrorId)
    Write-host $("{0}==>{1}<==`n" -f "ErrorDetails", $ex.ErrorDetails)
    Write-host  $("{0}==>{1}<==`n" -f "ErrorRecord", $ex.ToString())
    Write-host  $("{0}==>{1}<==`n" -f "InvocationInfo", $ex.InvocationInfo)
    Write-host  $("{0}==>{1}<==`n" -f "PSMessageDetails", $ex.PSMessageDetails)
    Write-host  $("{0}==>{1}<==`n" -f "CategoryInfo", $ex.CategoryInfo.ToString())
    Write-host -ForegroundColor DarkMagenta $("{0}==>{1}<==`n" -f "InvocationInfo", $( $ex.InvocationInfo | Format-List * -Force | Out-String ))
    Write-host -ForegroundColor DarkCyan $("{0}==>{1}<==`n" -f "InnerException", $(  $innerEx | Format-List * -Force | Out-String ))
    Write-host $("{0}==>{1}<==`n" -f "InnerException.ErrorRecord", $innerEx.ErrorRecord)
    Write-host $("{0}==>{1}<==`n" -f "InnerException.Message", $innerEx.Message)
#>
<#
   As robocopy exits with a non zero number we have to check in the exception ErrorRecord and extract the real ExitCode number
   Eg

   Robocopy.exe ExitCode:1

   This is success for Robocopy.
   If Ruusty.ReleaseUtilities\start-exe throws a real exception the exception ErrorRecord  is

   Robocopy.exe ExitCode:-1

#>
    $exitCodeStr = $ex.ToString()
    $exitCode = $exitCodeStr.Split(":")[1]
    Write-host $("==>{0}==>{1}<==`n" -f "RealExitCode", $exitCode)
    if ($exitCode -gt 7 -or $exitCode -lt 0)
    {
      Write-host -ForegroundColor Red  $($ex | Format-List * -Force | Out-String)
      Write-Error $innerEx
    }
  }

  <#Put the History and version in the build folder.

  foreach ($i  in @($ProjHistoryPath, $ProjVersionPath,$ProjReadmePath))
  {
    $f = [System.io.Path]::GetFileName($i)
    $d = join-path $ProjBuildPath $f
    ##Copy-Item -path $i -Destination "$ProjBuildPath\RuustyTools"
    Copy-Item -path $i -Destination $d
  }
#>
  Write-Host "Attempting Versioning Markdown in $ProjBuildPath"
  Get-ChildItem -Recurse -Path $ProjBuildPath -Filter "*.md" | ForEach-Object{
    Ruusty.ReleaseUtilities\Set-VersionReadme -path $_.FullName  -version $version -datetime $now
  }

  Write-Host "Attempting to Convert Markdown to Html"
  Import-Module "$PSScriptRoot\md2html"
  Convert-Markdown2Html -path $ProjBuildPath -recurse -verbose

  Write-Host "Attempting to create zip file with '$zipArgs'"
  if (Test-Path -Path $ProjPackageZipPath -Type Leaf){ Remove-Item -path $ProjPackageZipPath}
  Ruusty.ReleaseUtilities\start-exe $7zipExe -ArgumentList $zipArgs -workingdirectory $ProjBuildPath

  #Copy README and history
  #Copy-Item -Path $(Join-Path $ProjBuildPath "README.html") -Destination $ProjDistPath
  #Copy-Item -Path $ProjHistoryPath -Destination $ProjDistPath
}


Task Compile-nupkg -description "Compile Chocolatey nupkg from nuspec" -depends compile-nupkg-single, compile-nupkg-multi {
  Write-Host -ForegroundColor Magenta "Done compiling Chocolatey packages"
}


Task Compile-nupkg-single -description "Compile single Chocolatey nupkg from nuspec" -PreCondition { ($sdlcs -and $sdlcs.Count -eq 1) }  {
  $versionNum = Get-Content $ProjVersionPath
  Write-Host $("Compiling {0}" -f $ProjNuspecPath)
  exec { & $ChocoExe pack $ProjNuspecPath --version $versionNum }
}


Task Compile-nupkg-multi -description "Compile Multiple Chocolatey sdlc nupkg from nuspec" -PreCondition { ($sdlcs -and $sdlcs.Count -gt 1)} {
  $versionNum = Get-Content $ProjVersionPath
  Write-Host $("Compiling {0}" -f $ProjNuspecPath)
  foreach ($sdlc in $sdlcs)
  {
    Write-Host "Attempting to get Chocolatey Install Scripts for $sdlc"
    Copy-Item -path "tools" -Destination $ProjDistPath -Recurse -force
    Ruusty.ReleaseUtilities\Set-Token -Path $(join-path $ProjDistPath "tools/properties.ps1") -key "SDLC" -value $sdlc

    Write-Host "Attempting to get *.nuspec  for $sdlc"
    Copy-Item -path $ProjNuspecPath -Destination $ProjDistPath
    Ruusty.ReleaseUtilities\Set-Token -Path $(join-path $ProjDistPath $ProjNuspec) -key "SDLC" -value $sdlc
    Ruusty.ReleaseUtilities\Set-Token -Path $(join-path $ProjDistPath $ProjNuspec) -key "SDLC_SUFFIX" -value "-${sdlc}"

    exec { & $ChocoExe pack $(join-path $ProjDistPath $ProjNuspec) --version $versionNum --outputdirectory $ProjDistPath }
  }
}


Task Distribute -description "Distribute the deliverables to Deliver" -PreCondition { ($isMaster) } -depends DistributeTo-Delivery, distribute-nupkg-single, distribute-nupkg-multi {
  Write-Host -ForegroundColor Magenta "Done distributing deliverables"
}


Task DistributeTo-Delivery -description "Copy Deliverables to the Public Delivery Share" -PreCondition {$false} {
  $versionNum = Get-Content $ProjVersionPath
  $DeliveryCopyArgs = @{
    path   = @("$ProjDistPath/*.zip", "$ProjDistPath/README.*", "$ProjDistPath/*.nupkg","$ProjDistPath/tools/*.zip",$ProjHistoryPath)
    destination = $ExecutionContext.InvokeCommand.ExpandString($ProjDeliveryPath)
    Verbose = $VerbosePreference
  }
  Write-Host $("Attempting to copy deliverables to {0}" -f $DeliveryCopyArgs.Destination)
  if (!(Test-Path $DeliveryCopyArgs.Destination)) { mkdir -Path $DeliveryCopyArgs.Destination }
  Copy-Item @DeliveryCopyArgs
  dir $DeliveryCopyArgs.destination | out-string | write-host
}


Task Distribute-nupkg-single -description "Push nupkg to Chocolatey Feed" -PreCondition { (($sdlcs -ne $null) -and $sdlcs.Count -eq 1) } {
  $versionNum = Get-Content $ProjVersionPath
  $nupkg = $ExecutionContext.InvokeCommand.ExpandString($ProjNuspecPkgVersionPath)
  Write-Host $("Pushing {0}" -f $nupkg)
  exec { & $ChocoExe  push $nupkg -s $CoreChocoFeed }
}


Task Distribute-nupkg-multi -description "Push multiple sdlc nupkg to Chocolatey Feed" -PreCondition { (($sdlcs -ne $null) -and $sdlcs.Count -gt 1) } {
  $versionNum = Get-Content $ProjVersionPath
  Push-Location $ProjDistPath
  foreach ($sdlc in $sdlcs)
  {
    $LocalNuspecPkgVersionName = '${ProjNuspecName}-${sdlc}.${versionNum}.nupkg'
    $nupkg = $ExecutionContext.InvokeCommand.ExpandString($LocalNuspecPkgVersionName)
    Write-Host $("Pushing {0}" -f $nupkg)
    exec { & $ChocoExe  push $nupkg -s $CoreChocoFeed }
  }
  Pop-Location
}


Task clean-dirs {
  if ((Test-Path $ProjBuildPath)) { Remove-Item $ProjBuildPath -Recurse -force -ErrorAction Continue }
  if ((Test-Path $ProjDistPath)) { Remove-Item $ProjDistPath -Recurse -force }
}


Task create-dirs {
  if (!(Test-Path $ProjBuildPath)) { mkdir -Path $ProjBuildPath }
  if (!(Test-Path $ProjDistPath)) { mkdir -Path $ProjDistPath }
}


task clean -description "Remove all generated files" -depends clean-dirs {
  if ($isMaster)
  {
    <# Remove only files ignored by Git.
    If the Git configuration variable clean.requireForce is not set to false, git clean will refuse to delete files or directories unless given -f, -n or -i.
    Git will refuse to delete directories with .git sub directory or file unless a second -f is given.
    #>
    exec { & $GitExe "clean" -f -X }
  }
  else
  {
    exec { & $GitExe "clean" -f -X --dry-run }
  }
 }


Task Clean-DryRun -description "Remove all generated files" -depends clean-dirs {
  exec { & $GitExe "clean" -f -X --dry-run }
}


Task set-version -description "Create the file containing the version" {
  $version = Ruusty.ReleaseUtilities\Get-Version -Major $ProjMajorMinor.Split(".")[0] -minor $ProjMajorMinor.Split(".")[1]
  Set-Content $ProjVersionPath $version.ToString()
  Write-Host $("Version:{0}" -f $(Get-Content $ProjVersionPath))
}


Task set-versionAssembly -description "Version the AssemblyInfo.cs" {
  $versionNum = Get-Content $ProjVersionPath
  $version = [system.Version]::Parse($versionNum)
  Ruusty.ReleaseUtilities\Set-VersionAssembly "CmdletRuusty\Properties\AssemblyInfo.cs" $version
}


Task tag-version -description "Create a tag with the version number" -PreCondition { $isMaster } {
  $versionNum = Get-Content $ProjVersionPath
  exec { & $GitExe "tag" "V$versionNum" }
}


Task Display-version -description "Display the current version" {
  $versionNum = Get-Content $ProjVersionPath
  Write-Host $("Version:{0}" -f $versionNum)
}


Task git-revision -description "" {
  exec { & $GitExe "describe" --tag }
}


Task git-history -description "Create git history file" {
  exec { & $GitExe log --since="$ProjHistorySinceDate" --graph --oneline --decorate } | Set-Content $ProjHistoryPath
}


Task git-status -description "Stop the build if there are any uncommitted changes" -PreCondition { $isMaster }  {
  $rv = exec { & $GitExe status --short  --porcelain }
  $rv | write-host

  #Extras
  #exec { & git.exe ls-files --others --exclude-standard }

  if ($rv)
  {
    throw $("Found {0} uncommitted changes" -f ([array]$rv).Count)
  }
}


Task Show-Deliverable -description "Show location of deliverables and open Explorer at that location" {
  $versionNum = Get-Content $ProjVersionPath
  $Spec = $ExecutionContext.InvokeCommand.ExpandString($ProjDeliveryPath)
  Write-Host $('Deliverable here : {0}' -f $Spec)
  exec { & cmd.exe /c explorer.exe $Spec }
  dir $Spec | out-string | write-host
}


Task Show-Choco-Deliverable -description "Show the Chocolatey nupkg packages/s in the chocolatey Feed (Assumes hosted on a UNC path)"{
  $versionNum = Get-Content $ProjVersionPath
  $LocalNuspecPkgVersionName = $ExecutionContext.InvokeCommand.ExpandString('${ProjNuspecName}*.${versionNum}.nupkg')
  $Spec = Join-Path -path $CoreChocoFeed -childpath $LocalNuspecPkgVersionName
  Write-Host $('Chocolatey goodness here : {0}' -f $Spec)
  dir $Spec | out-string | write-host
  (resolve-path $Spec).ProviderPath | out-string | write-host
}


Task Show-Settings -description "Display the psake configuration properties variables"   {
  Write-Verbose("Verbose is on")
  Get-Variable -name $script:config_vars -ea Continue | sort -Property name -CaseSensitive -unique | Format-Table -property name, value -autosize | Out-String -Width 2000 | Out-Host
}


Task Show-SettingsVerbose -description "Display the psake configuration properties variables as a list"   {
  Write-Verbose("Verbose is on")
  Get-Variable -name $script:config_vars -ea Continue | sort -Property name -CaseSensitive -unique | format-list -Expand CoreOnly -property name, value | Out-String -Width 2000 | Out-Host
}


Task set-buildList -description "Generate the list of files to go in the zip deliverable" {
  #Create file containing the list of files to zip. Check it into git.
  $scratchFile = Join-Path -path $env:TMP -ChildPath $([System.IO.Path]::GetRandomFileName())
  $RoboCopyLog = Join-Path -Path $env:TMP -ChildPath $('RoboCopyLog-{0}.txt' -f $([System.IO.Path]::GetRandomFileName()))
  #Create a random empty directory
  $RoboTarget = Join-Path -path $env:TMP -ChildPath $([System.IO.Path]::GetRandomFileName())
  mkdir $RoboTarget
  $RoboArgs = @($RoboSrc, $RoboTarget, '/S', '/XD', $XD ,'/XF' ,$XF ,'/L' ,$('/LOG:{0}'-f $RoboCopyLog) ,'/FP','/NDL' ,'/NP','/X','/njh','njs')
  Write-Host $('Robocopy.exe {0}' -f $RoboArgs -join " ")

  try
  {
    Ruusty.ReleaseUtilities\start-exe "Robocopy.exe" -ArgumentList $RoboArgs #-workingdirectory $ProjBuildPath
  }
  catch [Exception] {
    $ex = $_
    $innerEx = $ex.Exception
<#
   As robocopy exits with a non zero number we have to check in the exception ErrorRecord and extract the real ExitCode number
   Eg

   Robocopy.exe ExitCode:1

   This is success for Robocopy.
   If Ruusty.ReleaseUtilities\start-exe throws a real exception the exception ErrorRecord  is

   Robocopy.exe ExitCode:-1

#>
    $exitCodeStr = $ex.ToString()
    $exitCode = $exitCodeStr.Split(":")[1]
    Write-host $("==>{0}==>{1}<==`n" -f "RealExitCode", $exitCode)
    if ($exitCode -gt 7 -or $exitCode -lt 0)
    {
      Write-host -ForegroundColor Red  $($ex | Format-List * -Force | Out-String)
      Write-Error $innerEx
    }
  }

  $matches = (Select-String -simple -Pattern "    New File  " -path $RoboCopyLog).line
  $csv = $matches | ConvertFrom-Csv -Delimiter "`t" -Header @("H1", "H2", "H3", "H4", "H5")
  $pathPrefix = Split-Path -Parent $RoboSrc
  $pathPrefix = ($pathPrefix.Trim('"')).Replace("/", "\").Replace("\", "\\") + "\\"
  Write-Verbose "Removing PathPrefix $pathPrefix from $RoboCopyLog"

  #Remove the Absolute Path prefix
  ($csv.h5) | set-content -Path $scratchFile
  #@((Split-Path -path $ProjHistoryPath -Leaf), (Split-Path -path $ProjVersionPath -Leaf)) | Add-Content -path $scratchFile
  $lines = Get-Content $scratchFile
  ($lines) -creplace $pathPrefix, "" | set-content -Path $scratchFile
  #Add back the html files from markdown files
  $html = (Select-String  "\.md$" $scratchFile).line
  $html -creplace "\.md$", ".html" | Add-Content -path $scratchFile
  Get-Content $scratchFile | Sort-Object -Unique | Set-Content -path $ProjPackageListPath
  Write-Host -ForegroundColor Magenta "Done Creating : $ProjPackageListPath"
}


Task ? -Description "Helper to display task info" -depends help {
}


Task help -Description "Helper to display task info" {
  Invoke-psake -buildfile $me -detaileddocs -nologo
  Invoke-psake -buildfile $me -docs -nologo
}


Task unit-test -PreCondition { $true }  {
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


Task Test -description "Pester tests" -PreCondition { $false } {
  $verbose = $false
  $result = invoke-pester -Script @{ Path = '.\src\SpaOmsGis.Tests.ps1'; Parameters = @{ Verbose = $false } } -OutputFile ".\src\SpaOmsGis.Tests.TestResults.xml" -PassThru -Verbose:$verbose
  Write-Host $result.FailedCount
  if ($result.FailedCount -gt 0)
  {
    Write-Error -Message $("Pester failed {0} tests" -f $result.FailedCount)
  }
}







