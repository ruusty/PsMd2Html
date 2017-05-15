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
$CSharp =
@'
using System;
using System.IO;
namespace Build.Utils{
    public static class Version {

        public static string RegexVersionPlSql(string pFileName, string pVersion){
            string s = "";     //Line containg the version: gr_VERSION constant VARCHAR2(200) := '4.3.0.0';
            using ( System.IO.StreamReader sr = new System.IO.StreamReader(pFileName) ) {
                s = @sr.ReadToEnd();
            }
            System.Text.RegularExpressions.RegexOptions   options = (System.Text.RegularExpressions.RegexOptions.Multiline | System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            System.Text.RegularExpressions.Regex          re = new System.Text.RegularExpressions.Regex(@"(?<versionProlog>^\s*gr_VERSION\s+CONSTANT\s+VARCHAR2\(\d{3,}\)\s*:=\s*')(?<verionsNum>[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)(?<versionSuffix>'\s*;)", options);
            string         replacement = String.Format("${{versionProlog}}{0}${{versionSuffix}}", pVersion);
            s = re.Replace(@s, replacement);
            using ( System.IO.StreamWriter sw = new System.IO.StreamWriter(pFileName, false, System.Text.Encoding.ASCII) ) {
                sw.Write(s);
            }
            return (replacement);
        }


        public static string RegexVersionModule(string pFileName, string pVersion){
            string s = "";     // string pVersion="4.3.1111.2222";
            using ( System.IO.StreamReader sr = new System.IO.StreamReader(pFileName) ) {
                s = @sr.ReadToEnd();
            }
            System.Text.RegularExpressions.RegexOptions   options = System.Text.RegularExpressions.RegexOptions.Multiline;
            System.Text.RegularExpressions.Regex          re = new System.Text.RegularExpressions.Regex(@"^\s*ModuleVersion.*", options);
            string         replacement = String.Format("ModuleVersion = '{0}'", pVersion);

            //Console.WriteLine(pFileName);
            //Console.WriteLine(pVersion);
            //Console.WriteLine(replacement);

            s = re.Replace(@s, replacement);

            using ( System.IO.StreamWriter sw = new System.IO.StreamWriter(pFileName, false, System.Text.Encoding.ASCII) ) {
                sw.Write(s);
            }
            return (s);
        }

        public static string RegexVersionReadme(string pFileName, string pVersion ,  string pDate){
            string s = "";     // string pVersion="01.01.01"; string pDate="15 may";
            using ( System.IO.StreamReader sr = new System.IO.StreamReader(pFileName) ) {
                s = @sr.ReadToEnd();
            }
            System.Text.RegularExpressions.RegexOptions   options = System.Text.RegularExpressions.RegexOptions.Multiline;
            System.Text.RegularExpressions.Regex          re = new System.Text.RegularExpressions.Regex(@"(?<ver>Version: *)([0-9.]+)(?<term>[\r|\n]+)(?<date>Date: *)([\w \d\-\/\.T]*)", options);
            string         replacement = String.Format("${{ver}}{0}${{term}}${{date}}{1}", pVersion, pDate);

            //Console.WriteLine(replacement);
            s = re.Replace(@s, replacement);


            using ( System.IO.StreamWriter sw = new System.IO.StreamWriter(pFileName, false, System.Text.Encoding.ASCII) ) {
                sw.Write(s);

            }
            return (s);
        }

    }


    public static class Tools {
        public static String FindFileUp(string cwd, string fileName){
            string startPath = Path.Combine(Path.GetFullPath(cwd), fileName);
            FileInfo file = new FileInfo(startPath);
            while ( !file.Exists ) {
                if ( file.Directory.Parent == null ) {
                    return null;
                }
                DirectoryInfo parentDir = file.Directory.Parent;
                file = new FileInfo(Path.Combine(parentDir.FullName, file.Name));
            }
            return file.FullName;
        }
    }


}


'@
Add-Type -TypeDefinition $CSharp -Language CSharp -Debug:$false

. "$PSScriptRoot\scripts\Start-Exe.ps1"
Import-Module GisOmsUtils

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
     ,"ProjHistorySinceDate"
     ,"ProjDeliveryPath"
     ,"ProjVersionNumber"
     ,"ProjPackageZipVersionPath"
     ,"CoreMajorMinor"
     ,"CoreChocoFeed"
     ,"sdlc"
  )
  $verbose = $false;
  $whatif = $false;
  $now = [System.DateTime]::Now
  write-verbose($("CurrentLocation={0}" -f $executionContext.SessionState.Path.CurrentLocation))
  $GlobalPropertiesName = $("GisOms.Chocolatey.properties.{0}.xml" -f $env:COMPUTERNAME)
  $GlobalPropertiesPath = [Build.Utils.Tools]::FindFileUp($PSScriptRoot, $GlobalPropertiesName)
  
  $GlobalPropertiesXML = New-Object XML
  $GlobalPropertiesXML.Load($GlobalPropertiesPath)
  
  $GitExe = $GlobalPropertiesXML.SelectNodes("/project/property[@name='git.exe']").value
  $7zipExe = $GlobalPropertiesXML.SelectNodes("/project/property[@name='tools.7zip']").value
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
  $ProjVersionNumber = Get-VersionNumber -Major $($CoreMajorMinor.split('.')[0]) -Minor $($CoreMajorMinor.split('.')[1])
  
  $ProjHistoryPath = Join-Path $ProjTopdir  "${ProjectName}.history.txt"
  $ProjVersionPath = Join-Path $ProjTopdir   "${ProjectName}.Build.Number"
  $ProjHistorySinceDate = "2015-05-01"
  $ProjNuspecPath = Join-Path $ProjTopdir "${ProjectName}.nuspec"
  $ProjNuspecPkgVersionPath = Join-Path $ProjTopdir  '${ProjectName}.${versionNum}.nupkg'

  
  Set-Variable -Name "sdlc" -Description "System Development Lifecycle Environment" -Value "UNKNOWN"
  $zipExe = "7z.exe"
  $zipArgs = 'a -bb2 -tzip "{0}" -ir0@"{1}"' -f $ProjPackageZipPath, $ProjPackageListPath # Get paths from file
  #$zipArgs = 'a -bb2 -tzip "{0}" -ir0!*' -f $ProjPackageZipPath #Everything in $ProjBuildPath
  
  Write-Host "Verbose: $verbose"
  Write-Verbose "Verbose"
  
}

task default -depends build
task test-build -depends Show-Settings, clean, git-history, set-version, unit-test,compile, compile-nupkg, distribute
task build -depends Show-Settings, git-status, clean, git-history, set-version, unit-test, compile, compile-nupkg, tag-version, distribute


task compile-nupkg -description "Compile Chocolatey nupkg from nuspec" {
  $versionNum = Get-Content $ProjVersionPath
  Write-Host $("Compiling {0}" -f $ProjNuspecPath)
  exec {& $ChocoExe pack $ProjNuspecPath --version $versionNum}
}

task distribute -description "Push nupkg to Chocolatey Feed"{
  $versionNum = Get-Content $ProjVersionPath
  $nupkg = $ExecutionContext.InvokeCommand.ExpandString($ProjNuspecPkgVersionPath)
  Write-Host $("Pushing {0}" -f $nupkg)
  exec { & $ChocoExe  push $nupkg -s $CoreChocoFeed }
}

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

task compile -description "Build Deliverable zip file" -depends clean, git-history, create-dirs {
  $versionNum = Get-Content $ProjVersionPath
 
  $copyArgs = @{
    path = @(
      "$ProjTopdir\md2html\*.*"
      ,$ProjHistoryPath
      ,$ProjVersionPath
     ) 
    exclude = @("*.log", "*.html", "*.credential", "*.TempPoint.psd1", "*.TempPoint.ps1", "*.Tests.ps1","*.psproj","*.psprojs", "Test-Module.ps1")
    destination = Join-Path $ProjBuildPath "md2html"
    recurse = $true
  }
  if (!(Test-Path $copyArgs.destination )) { mkdir -Path $copyArgs.destination  }
  Write-Host "Attempting to get deliverables"
  Copy-Item @copyArgs -verbose:$verbose
  
  $copyArgs.path = @("$ProjTopdir\md2html\examples\*.*"  )
  $copyArgs.destination = Join-Path $copyArgs.destination "examples"
  if (!(Test-Path $copyArgs.destination)) { mkdir -Path $copyArgs.destination }
  Copy-Item @copyArgs -verbose:$verbose
  
  
  Push-Location $ProjBuildPath;
  Write-Host "Attempting Versioning README.md"
  [void][Build.Utils.Version]::RegexVersionReadme("$ProjBuildPath/md2html/README.md", $versionNum, $ProjBuildDateTime)
  Write-Host "Attempting Versioning md2html.psd1 "
  [void][Build.Utils.Version]::RegexVersionModule("$ProjBuildPath/md2html/md2html.psd1", $versionNum)
  
  
  Write-Host "Attempting convert markdown to html"
  import-module -verbose:$verbose md2html; convertto-mdhtml -verbose:$verbose -recurse
  
  Write-Host "Attempting to create zip file with '$zipArgs'"
  
  start-exe $zipExe -ArgumentList $zipArgs -workingdirectory $ProjBuildPath
  Pop-Location;
  
  Copy-Item "$ProjBuildPath/README.*" $ProjDistPath
  
}


task clean -description "Remove all generated files" -depends clean-dirs

task set-version -description "Create the file containing the version" {
  Set-Content $ProjVersionPath $ProjVersionNumber
  Write-Host $("Version:{0}" -f $(Get-Content $ProjVersionPath))
  Write-Host $("Date   :{0}" -f $ProjBuildDateTime)
}

task tag-version -description "Create a tag with the version number" {
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

task git-history -description "Create git history file" {
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