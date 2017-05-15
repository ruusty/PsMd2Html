<#	
	.DESCRIPTION
	The md2html.Module.Tests.ps1 script lets you test the functions and other features of
	your module.

invoke-Pester -Script @{ Path = './md2html.Module.Tests.ps1';  } 
pester -testname "md2html" -Script @{ Path = './md2html.Module.Tests.ps1'; } 

#>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$verbose=$false
#Explicitly import the module for testing
Import-Module "$PSScriptRoot\..\md2html"

#Run each module function
Describe "md2html" {
  
  
  Context "Execution"  {
    It "Should Not convert non-md files"{
      Push-Location "$PSScriptRoot\test0"
      { convertTo-mdHtml -Verbose:$verbose } | Should not throw
      "New Text Document.html" | Should not exist
      Pop-Location
    }
    
    
    It "Should convert multiple md"{
      Push-Location "$PSScriptRoot\test1"
      { convertTo-mdHtml -Verbose:$verbose } | Should not throw
      @("Table.html"
         ,"!Readme.test1.html"
        ,"!Readme.test2.html"
        ,"!Readme.test3.html") | Should  exist
      Pop-Location
    }
    
    It "Html Create and modify date time should be same as md"{
      Push-Location "$PSScriptRoot\test1"
      { convertTo-mdHtml -Verbose:$verbose } | Should not throw
      @("Table.html"
         ,"!Readme.test1.html"
         ,"!Readme.test2.html"
         ,"!Readme.test3.html") | %{
        ((Get-ChildItem $_).lastwritetime -eq (Get-ChildItem $([System.IO.Path]::ChangeExtension($_, "html"))).lastwritetime) -and
        ((Get-ChildItem $_).CreationTime -eq (Get-ChildItem $([System.IO.Path]::ChangeExtension($_, "html"))).CreationTime)
      } | Should be $true
      Pop-Location
    }
    
    It "Should convert single md"{
      Push-Location "$PSScriptRoot\test2"
      {
        { convertTo-mdHtml -Verbose:$verbose } | Should not throw
        "!Readme.test1.html" | Should exist
        Pop-Location
      }
    }
    
    
    It "Should convert empty md"{
      Push-Location "$PSScriptRoot\test3"
      { convertTo-mdHtml -Verbose:$verbose } | Should not throw
      "!!Readme.test1.html" | Should exist
      Pop-Location
    }
    
    It "Should convert README md"{
      Push-Location "$PSScriptRoot\test4"
      { convertTo-mdHtml -Verbose:$verbose } | Should not throw
      @("README.html","about.html") | Should exist
      Pop-Location
    }
    
    
    It "Should Recurse README md"{
      Push-Location "$PSScriptRoot"
      { convertTo-mdHtml -Verbose:$verbose -recurse } | Should not throw
      Pop-Location
    }
    
    
    BeforeEach {
      Write-Verbose "Removing generated test file"
      Push-Location "$PSScriptRoot"
      Get-ChildItem "$PSScriptRoot" -Include "*.html" -Exclude "md2html.*.html" -Recurse | Remove-Item 
      pop-location
    }
    
  }
}

