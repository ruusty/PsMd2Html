# PowerShell Modules #

Modules to install using PsGet


## PsGet ##

[http://psget.net/](http://psget.net/ "Search and install PowerShell modules easy.")


	(new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex

[https://github.com/psget/psget](https://github.com/psget/psget)

If behind a fire wall, setup authentication with the proxy server
	
 	$wc = new-object Net.WebClient
	(new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex

	import-module psget

## posh-git ##

A PowerShell environment for Git

[https://github.com/dahlbyk/posh-git](https://github.com/dahlbyk/posh-git)

	import-module psget

	install-module posh-git

	install-module -ModuleUrl https://github.com/chaliy/psurl/raw/master/PsUrl/PsUrl.psm1


### PsUrl ###

[http://amonkeysden.tumblr.com/post/4829727898/mike-chaliys-personal-site-introducing-psurl-and](http://amonkeysden.tumblr.com/post/4829727898/mike-chaliys-personal-site-introducing-psurl-and)
[http://powertoe.wordpress.com/2010/08/10/corporate-powershell-module-repository-part-1-design-and-infrastructure/](http://powertoe.wordpress.com/2010/08/10/corporate-powershell-module-repository-part-1-design-and-infrastructure/)

	C:\dev\posh\modules [master +1 ~0 -0 | +4 ~2 -0 !]> install-module  -verbose -ModuleUrl https://github.com/chaliy/psurl/raw/master/PsUrl/PsUrl.psm1 -destination "c:\dev\posh\modules"
	VERBOSE: Module will be installed from https://github.com/chaliy/psurl/raw/master/PsUrl/PsUrl.psm1
	VERBOSE: Expecting the module 'PsUrl' to be installed in 'c:\dev\posh\modules\'
	"c:\dev\posh\modules\" is added to the PSModulePath environment variable
	VERBOSE: Create module folder at c:\dev\posh\modules\PsUrl
	Module PsUrl was successfully installed.
	VERBOSE: Loading module from path 'C:\dev\posh\modules\PsUrl\PsUrl.psm1'.
	VERBOSE: Importing function 'Get-Url'.
	VERBOSE: Importing function 'Get-WebContent'.
	VERBOSE: Importing function 'Send-WebContent'.
	VERBOSE: Importing function 'Write-Url'.
	VERBOSE: Importing alias 'gwc'.
	VERBOSE: Importing alias 'swc'.


### psake ###

	$ENV:PSModulePath

	C:\dev\posh\Modules\;d:\Users\russell\Documents\WindowsPowerShell\Modules\;d:\Users\russell\Documents\WindowsPowerShell\Modules\

Changed `$ENV:PSModulePath` to


	C:\dev\posh\Modules\;C:\Windows\System32\WindowsPowerShell\v1.0\modules\

Install psake

	import-module psget
	install-module psake
