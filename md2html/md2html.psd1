﻿<#
===========================================================================
Filename: md2html.psd1
-------------------------------------------------------------------------
Module Manifest
-------------------------------------------------------------------------
Module Name: md2html
===========================================================================
#>

@{

	# Script module or binary module file associated with this manifest
  RootModule  = 'md2html.psm1'

	# Version number of this module.
	ModuleVersion = '2.2.0.0'

	# Supported PSEditions
	CompatiblePSEditions   = 'Desktop'

	# ID used to uniquely identify this module
	GUID = '505392a6-9e58-4659-9f23-bc288d5f5e9d'

	# Author of this module
	Author = 'Russell'

	# Company or vendor of this module
	CompanyName = ''

	# Copyright statement for this module
	Copyright = '(c) 2018. All rights reserved.'

	# Description of the functionality provided by this module
	Description = 'A collection of PowerShell commands to convert Markdown files to static HTML.'

	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.1'

	# Name of the Windows PowerShell host required by this module
	PowerShellHostName = ''

	# Minimum version of the Windows PowerShell host required by this module
	PowerShellHostVersion = '7.1.0'

	# Minimum version of the .NET Framework required by this module
	DotNetFrameworkVersion = '4.6.2'

	# Minimum version of the common language runtime (CLR) required by this module
	CLRVersion = ''

	# Processor architecture (None, X86, Amd64, IA64) required by this module
	ProcessorArchitecture = ''

	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @()

	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies = @(
		'./lib/net6.0/Markdig.dll'
		)

	# Script files (.ps1) that are run in the caller's environment prior to
	# importing this module
	ScriptsToProcess = @()

	# Type files (.ps1xml) to be loaded when importing this module
	TypesToProcess = @()

	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @()

	# Modules to import as nested modules of the module specified in
	# ModuleToProcess
  NestedModules = @()

	# Functions to export from this module
	FunctionsToExport = @('Convert-Markdown2Html','Convert-Markdown2Pdf') #For performanace, list functions explicity

	# Cmdlets to export from this module
	CmdletsToExport = '*'

	# Variables to export from this module
	VariablesToExport = '*'

	# Aliases to export from this module
	AliasesToExport = @('md2Html','md2pdf') #For performanace, list alias explicity

	# List of all modules packaged with this module
	ModuleList = @()

	# List of all files packaged with this module
	FileList = @()

	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{

		#Support for PowerShellGet galleries.
		PSData = @{

			# Tags applied to this module. These help with module discovery in online galleries.
			# Tags = @()

			# A URL to the license for this module.
			# LicenseUri = ''

			# A URL to the main website for this project.
			# ProjectUri = ''

			# A URL to an icon representing this module.
			# IconUri = ''

			# ReleaseNotes of this module
			 ReleaseNotes = 'Hello'

		} # End of PSData hashtable
		#Configuration for module cmdlets
		#Rooted from the folder of this manifest
		Config = @{
			None 			     = "data/none.css"
			CssPath              = "data/markdownpad-github.min.css"
			HighlightJsCssPath   = "data/vs.min.css"
			#Highlight local
            HighlightJsPathLocal = 'https://highlightjs.org/static/highlight.pack.js'
			#Highlight on the Web
			HighlightJsPath      ='https://highlightjs.org/static/highlight.pack.js'
		}
	} # End of PrivateData hashtable
}