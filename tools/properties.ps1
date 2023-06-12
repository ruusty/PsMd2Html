# Set path that will not fail, 2 levels up from  LOCALAPPDATA
#e.g. LOCALAPPDATA=C:\Users\Russell\AppData\Local
# Should be a local disk

$installRootDirPath =  Join-Path -Path $(Join-Path -Path $([Environment]::GetFolderPath('MyDocuments') ) -ChildPath "WindowsPowerShell") -ChildPath "Modules"
$moduleName         = "md2html" #Top filepath in zip file
$moduleDirPath      = Join-Path -Path $installRootDirPath -ChildPath $moduleName
$ZipName            = "PS$moduleName.zip"

$config_vars += @(
    'installRootDirPath'
    , 'moduleName'
    , 'moduleDirPath'
    , 'ZipName'
)

$config_vars | Get-Variable | Sort-Object -unique -property "Name" | Select-Object Name, value | Format-Table | Out-Host

