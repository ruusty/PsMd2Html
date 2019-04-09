 #requires -version 5.0
#Get public and private function definition files.

$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Exclude *.Tests.ps1 -ErrorAction SilentlyContinue | sort-object Basename)
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


Add-Type -Path $(Join-Path $PSScriptRoot "Markdig.dll")

Set-Alias -name ConvertTo-mdHtml -value convert-Markdown2Html -Description "Backward compatibility V2"
Set-Alias -name md2Html -value convert-Markdown2Html -Description "Backward compatibility V2"
set-alias -name Convert-md2Html -value convert-Markdown2Html
Export-ModuleMember -Function $Public.Basename -alias  ConvertTo-mdHtml, md2Html, Convert-md2Html 
