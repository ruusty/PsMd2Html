<#
  .SYNOPSIS
    Wrapper on tests in PesterPath to produce pretty reports
    
  .EXAMPLE
    .\Publish-PesterTests-Module.Tests.ps1
  
  .example
  .\Publish-PesterTests-Module.Tests.ps1 -verbose

  .NOTES
    Additional information about the file.
#>
[CmdletBinding()]
param
(
    [Parameter(Mandatory = $false,
        Position = 1)]
    [string]$PesterPath = '*.Tests.ps1',
    [string]$OutDir = $PSScriptRoot,
    [string]$iso_datetime = $(get-date -uformat "%Y-%m-%dT%H-%M-%S")
)
#region setup
# Get the command name
$CommandName = $PSCmdlet.MyInvocation.InvocationName;
# Get the list of parameters for the command
"${CommandName}: Input", (((Get-Command -Name ($PSCmdlet.MyInvocation.InvocationName)).Parameters) |
        % { Get-Variable -Name $_.Values.Name -ErrorAction SilentlyContinue; } |
        Format-Table -AutoSize @{ Label = "Name"; Expression = { $_.Name }; }, @{ Label = "Value"; Expression = { (Get-Variable -Name $_.Name -EA SilentlyContinue).Value }; }) |
    Out-String | write-verbose
#endregion

<#If ([IntPtr]::Size -eq 4)
{
  Write-Host "32 bit Process to use 32bit Oracle Drivers"
}
Else
{
  Write-Host "64 bit"
  throw "Not 32 bit Powershell"
}
#>

$Jobname = [System.io.Path]::GetFileNameWithoutExtension($(Split-Path -Path $PSScriptRoot -parent ))
$Jobname = '{0}-Module' -f $Jobname

$OutFiles = Join-Path $OutDir "$JobName-Results.*"
$OutputXmlFile = Join-Path $OutDir "$JobName-Results.xml"
$OutputHtmlFile = [System.IO.Path]::ChangeExtension($OutputXmlFile, '.html')
$zipPath = [System.IO.Path]::ChangeExtension($OutputHtmlFile, ".$iso_datetime.zip")


@('zipPath', 'OutputXmlFile', 'OutputHtmlFile', 'PesterPath', 'JobName', 'OutFiles') |
    ForEach-Object { Get-Variable -name $_ -ea Continue} | Format-Table -AutoSize @{ Label = "Name"; Expression = { $_.Name }; }, @{ Label = "Value"; Expression = { (Get-Variable -Name $_.Name -EA SilentlyContinue).Value }; } | Out-String | write-verbose

Remove-Item -Path $OutFiles -Include @('html', '*.xml') -Confirm

$Params = @{
    Verbose = ($VerbosePreference -eq 'Continue')
}

$params | Format-Table | out-string -width 120 | write-verbose

Invoke-Pester -Script @{ Path = $PesterPath; Parameters = $Params } -OutputFormat NUnitXml -OutputFile $OutputXmlFile

& ReportUnit.exe $OutputXmlFile $OutputHtmlFile | out-null

& 7z.exe a -tzip -bb3 $zipPath $OutputXmlFile $OutputHtmlFile

