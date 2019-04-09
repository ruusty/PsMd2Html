write-host chocolateyPackageFolder  =$env:chocolateyPackageFolder
write-host chocolateyPackageName    =$env:chocolateyPackageName
write-host chocolateyPackageVersion =$env:chocolateyPackageVersion

$tools = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
.  $(join-path $tools "properties.ps1")

UnInstall-ChocolateyZipPackage -PackageName $env:chocolateyPackageName -ZipFileName $ZipName

