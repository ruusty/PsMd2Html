# md2html <!-- omit in top --> 

- [md2html ](#md2html-omit-in-top)
- [SHORT DESCRIPTION](#short-description)
- [EXAMPLES](#examples)
- [NOTE](#note)
- [TROUBLESHOOTING NOTE](#troubleshooting-note)
- [SEE ALSO](#see-also)
- [KEYWORDS](#keywords)
  - [Markdown Examples](#markdown-examples)
  - [Markdig](#markdig)
  - [CommonMark](#commonmark)
  - [Resources](#resources)
  - [highlightjs](#highlightjs)
  - [Changes](#changes)

# SHORT DESCRIPTION #

md2html is a PowerShell module to automate converting Markdown files into html files and pdf files.

Uses the [Markdig](https://github.com/lunet-io/markdig)__ CommonMark compliant, extensible Markdown processor for .NET.


# EXAMPLES #

~~~powershell
convert-Markdown2Html -path *.md
~~~

~~~powershell
"*.md", 'README*.md', "..\Specification\*.md", "..\Specification\*.md" | Convert-Markdown2Html -verbose -recurse -Hilite
~~~

~~~powershell
"*.md", 'README*.md', "..\Specification\*.md", "..\Specification\*.md" | Convert-Markdown2Html -verbose -recurse -HighlightLocal
~~~

Using alias

~~~powershell
md2html -verbose -recurse
~~~

~~~powershell
Convert-md2html -verbose -recurse
~~~


# NOTE #

Uses `wkhtmltopdf.exe` included with *Markdown Monster*

# TROUBLESHOOTING NOTE #

```powershell
import-module md2html -verbose
get-module md2html | select -expand ExportedCommands
$(get-module md2html).ExportedCommands.Keys
```

Installed here  

```powershell
$installRootDirPath =  Join-Path -Path $(Join-Path -Path $([Environment]::GetFolderPath('MyDocuments') ) -ChildPath "PowerShell") -ChildPath "Modules"
```

```powershell
import-module  d:\Users\Russell\Documents\PowerShell\Modules\ms2html\md2html.psd1
```

Get help

```powershell
import-module md2html -verbose
get-module md2html | select -expand ExportedCommands
$(get-module md2html).ExportedCommands.Keys
```

~~~powershell
import-module md2html
$(get-module md2html).ExportedCommands.Keys |% {get-help $_ -detailed}
~~~

~~~powershell
import-module md2html

get-module md2html | select -expand ExportedCommands
$(get-module md2html).ExportedCommands.Keys
~~~


# SEE ALSO #

```powershell
$(get-module md2html).ExportedCommands.Keys |% {get-help $_}
```

~~~powershell
@echo off
powershell -NoProfile -ExecutionPolicy unrestricted import-module -verbose md2html\Convert-Markdown2Html  
~~~


# KEYWORDS #

- Markdown
- Markdig


[&uarr;](#top)

## Markdown Examples ##

- __[markdown-it](examples\markdown-it.demo.html)__
- __[ PHP Markdown Extra ](https://michelf.ca/projects/php-markdown/extra/#spe-attr)__
- __[github flavored markdown (GFM)](examples\github-flavored-markdown.sample_content.html)__  
  
: Sample grid table.

+---------------+---------------+--------------------+
| Fruit         | Price         | Advantages         |
+===============+===============+====================+
| Bananas       | $1.34         | - built-in wrapper |
|               |               | - bright color     |
+---------------+---------------+--------------------+
| Oranges       | $2.10         | - cures scurvy     |
|               |               | - tasty            |
+---------------+---------------+--------------------+  

: Another Sample grid table.

|   Fruit | Price | Advantages         |
|--------:|:-----:|:-------------------|
| Bananas | $1.34 | - built-in wrapper |
|         |       | - bright color     |
| Oranges | $2.10 | - cures scurvy     |
|         |       | - tasty            |

Three consecutive dots ... into an ellipsis entity

: Sample task list

- [ ] a task list item
- [ ] list syntax required
- [ ] normal **formatting**, @mentions, #1234 refs
- [ ] incomplete
- [x] completed

:::spoiler
This is a spoiler
:::

[&uarr;](#top)

## Markdig ##

The  [Markdig.Signed](https://www.nuget.org/packages/Markdig.Signed/) NuGet package provides the _net40_ signed assemblies.

[&uarr;](#top)

## CommonMark ##

- __[commonmark.org](http://commonmark.org)__
- Specification for __[CommonMark](http://spec.commonmark.org)__.
- CommonMark __[code](http://code.commonmark.org)__ on GitHub.
- The official __[dingus](http://try.commonmark.org)__ which allows people to experiment.

[&uarr;](#top)

## Resources ##

- [Markdig.Signed](https://www.nuget.org/packages/Markdig.Signed/) NuGet package provides signed assemblies.
- [mastering-markdown](https://guides.github.com/features/mastering-markdown)
- <https://www.nuget.org/packages/Markdig.Signed>
- <https://github.com/lunet-io/markdig>
- [Markdown Here Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Here-Cheatsheet)
- <https://github.com/gitlabhq/gitlabhq/blob/master/doc/user/markdown.md>
- <https://www.markdownguide.org/extended-syntax/>
- <http://www.tablesgenerator.com/markdown_tables>

[&uarr;](#top)

## highlightjs ##

- <https://highlightjs.org/download/>
- <https://highlightjs.readthedocs.io/en/latest/>

[&uarr;](#top)

## Changes ##

- 2019-06-10
  - Markdig.dll markdig.signed.0.17.0
  - Markdig pipeline configured with UseAutoIdentifiers(Github)
- 2019-02-14
  - Markdig.dll markdig.signed.0.15.7.0

[&uarr;](#top)
