# md2html #

~~~
Version:        1.0.0.0
Date:           2016-05-01
~~~

md2html is a PowerShell module to automate converting Markdown into html files. 

Uses the <a href="https://github.com/lunet-io/markdig" target="_blank">Markdig</a> CommonMark compliant, extensible Markdown processor for .NET.

## Usage

```powershell
import-module md2html
get-help convertto-mdhtml -detailed
convertto-mdhtml -verbose -recurse
New-Alias -Name md2html -Value convertTo-mdHtml -Description "Converts Markdown documents to html"
md2html -verbose -recurse
```

## Module details
```powershell
import-module md2html -verbose
get-module md2html | select -expand ExportedCommands
$(get-module md2html).ExportedCommands.Keys
```

```powershell
$(get-module md2html).ExportedCommands.Keys |% {get-help $_}
```





### CommonMark ###

<http://commonmark.org>


<http://spec.commonmark.org>

The official specification for CommonMark.

<http://code.commonmark.org>

The official reference implementation and validation test suite on GitHub.

<http://talk.commonmark.org>

The official Discourse discussion area and mailing list.

<http://try.commonmark.org>

The official dingus which allows people to experiment. 


<https://github.com/Knagis/CommonMark.NET>

Implementation of [CommonMark](http://spec.commonmark.org/) specification in C# for converting Markdown documents to HTML. .



### Resources ###

<https://guides.github.com/features/mastering-markdown>




