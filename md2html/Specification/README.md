# README <!-- omit in toc --> #

<link rel="shortcut icon" type="image/jpg" href="favicon.png"/>

Serves:4

- [README ](#readme-)
  - [TEST](#test)
  - [Manual Testing](#manual-testing)



## TEST ##

Test scripts are written in Pester 4.6.0 so must :-

```powershell-interactive
  import-module -RequiredVersion 4.6.0 pester
```


## Manual Testing ##

```
cd E:\Projects-Ruusty\psmd2html\md2html\Specification
get-module ../ -listavailable
import-module ../ -verbose
convert-Markdown2Html -path *.md
```


[&uarr;](#top)