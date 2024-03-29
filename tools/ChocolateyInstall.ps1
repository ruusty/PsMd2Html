[CmdletBinding()]
param ( )

end {

write-host chocolateyPackageFolder  =$env:chocolateyPackageFolder
write-host chocolateyPackageName    =$env:chocolateyPackageName
write-host chocolateyPackageVersion =$env:chocolateyPackageVersion

#write-host `$ErrorActionPreference=$ErrorActionPreference
#write-host `$VerbosePreference=$VerbosePreference

$tools = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
.  $(join-path $tools "properties.ps1")

$ZipPath = $(join-path $tools $ZipName)

if (!(Test-Path $installRootDirPath)) { New-Item $installRootDirPath -ItemType Directory -force | Out-Null }
#Remove everything under $moduleDirPath

if (Test-Path $moduleDirPath) { Remove-Item -path $(Join-Path -Path $moduleDirPath -ChildPath "*") -Recurse -Force }

Get-ChocolateyUnzip -PackageName $env:chocolateyPackageName -FileFullPath $ZipPath -Destination $installRootDirPath
$psModulePath = [Environment]::GetEnvironmentVariable('PSModulePath','Machine')

# if installation dir path is not already in path then add it.
if(!($psModulePath.Split(';').Contains($installRootDirPath))){
  Write-Host "Attempting to add $installRootDirPath to '$env:PSModulePath'"
    # trim trailing semicolon if exists
    $psModulePath = $psModulePath.TrimEnd(';');
    # append path
    $psModulePath = $psModulePath + ";$installRootDirPath"
    # save
    Install-ChocolateyEnvironmentVariable -variableName "PSModulePath" -variableValue $psModulePath -variableType 'Machine'
}
}

begin {
  function Install-ChocolateyPowershellModule {
    param(
      [string] $packageName,
      [string] $psModuleFullPath,
      [string] $cmdName
    )
    Write-Debug "Running 'Install-ChocolateyPowershellCommand' for $packageName with ${psModuleFullPath}:`'$psModuleFullPath`' ";

    try {

      $nugetPath = $env:ChocolateyInstall
      $nugetExePath = Join-Path $nuGetPath 'bin'
      $packageBatchFileName = Join-Path $nugetExePath "$($cmdName).bat"
      Write-Host "Adding $packageBatchFileName and pointing it to powershell module $psModuleFullPath"
      "@echo off
powershell -NoProfile -ExecutionPolicy unrestricted import-module -verbose `'$psModuleFullPath`'; convert-markdown2html %* -verbose"| Out-File $packageBatchFileName -encoding ASCII
    }
    catch {
      throw $_.Exception
    }
  }

}