#requires -version 5.0
#Get public and private function definition files.

$Public  = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Exclude *.Tests.ps1 -ErrorAction SilentlyContinue | sort-object Basename)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Exclude *.Tests.ps1 -ErrorAction SilentlyContinue)


#Dot source the files
Foreach ($import in @($Public + $Private))
{
  Try
  {
    . $import.fullname
  }
  Catch
  {
    Write-Error -Message "Failed to import function $($import.fullname): $_"
  }
}

# Here I might...
# Read in or create an initial config file and variable
# Export Public functions ($Public.BaseName) for WIP modules
# Set variables visible to the module and its functions only

Set-Alias -name md2Html -value Convert-Markdown2Html -Description "Backward compatibility V2"
Set-Alias -name md2pdf -value convert-Markdown2pdf

Export-ModuleMember -Function $Public.Basename
Export-ModuleMember -Function * -Alias *
