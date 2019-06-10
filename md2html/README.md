# md2html <!-- omit in toc --> #

~~~plaintext
Version:        4.3.6415.8603
Date:           2017-05-15T23-53
~~~

<a name="TOC"></a>

- [Description](#description)
- [Powershell Usage](#powershell-usage)
  - [Example Usage](#example-usage)
    - [Module Commands](#module-commands)
    - [Get help](#get-help)
- [Cmd Usage](#cmd-usage)
- [Markdown Examples](#markdown-examples)
- [Markdig](#markdig)
- [CommonMark](#commonmark)
- [Resources](#resources)
- [highlightjs](#highlightjs)
- [Changes](#changes)

[&uarr;](#TOC)

## Description ##

md2html is a PowerShell module to automate converting Markdown files into html files.

Uses the __[Markdig](https://github.com/lunet-io/markdig)__ CommonMark compliant, extensible Markdown processor for .NET.

[&uarr;](#TOC)

## Powershell Usage ##

~~~powershell
convert-Markdown2Html -path *.md
~~~

~~~powershell
"*.md", 'README*.md', "..\Specification\*.md", "..\Specification\*.md" | Convert-Markdown2Html -verbose -recurse -Hilite
~~~

~~~powershell
"*.md", 'README*.md', "..\Specification\*.md", "..\Specification\*.md" | Convert-Markdown2Html -verbose -recurse -HighlightLocal
~~~

### Example Usage ###

~~~powershell
md2html -verbose -recurse
~~~

~~~powershell
Convert-md2html -verbose -recurse
~~~

```dos
md2html -verbose -recurse
```

#### Module Commands ####

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

#### Get help ####

```powershell
$(get-module md2html).ExportedCommands.Keys |% {get-help $_}
```

[&uarr;](#TOC)

## Cmd Usage ##

~~~dos
md2html
~~~

`md2html.bat` is installed by _Chocolatey_

~~~powershell
@echo off
powershell -NoProfile -ExecutionPolicy unrestricted import-module -verbose md2html\Convert-Markdown2Html  
~~~

[&uarr;](#TOC)

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

| Fruit         | Price         | Advantages         |
|---:           |:------:       |:----               |
| Bananas       | $1.34         | - built-in wrapper |
|               |               | - bright color     |
| Oranges       | $2.10         | - cures scurvy     |
|               |               | - tasty            |

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

[&uarr;](#TOC)

## Markdig ##

The  [Markdig.Signed](https://www.nuget.org/packages/Markdig.Signed/) NuGet package provides the _net40_ signed assemblies.

[&uarr;](#TOC)

## CommonMark ##

- __[commonmark.org](http://commonmark.org)__
- Specification for __[CommonMark](http://spec.commonmark.org)__.
- CommonMark __[code](http://code.commonmark.org)__ on GitHub.
- The official __[dingus](http://try.commonmark.org)__ which allows people to experiment.

[&uarr;](#TOC)

## Resources ##

- [Markdig.Signed](https://www.nuget.org/packages/Markdig.Signed/) NuGet package provides signed assemblies.
- [mastering-markdown](https://guides.github.com/features/mastering-markdown)
- <https://www.nuget.org/packages/Markdig.Signed>
- <https://github.com/lunet-io/markdig>
- [Markdown Here Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Here-Cheatsheet)
- <https://github.com/gitlabhq/gitlabhq/blob/master/doc/user/markdown.md>
- <https://www.markdownguide.org/extended-syntax/>
- <http://www.tablesgenerator.com/markdown_tables>

[&uarr;](#TOC)

## highlightjs ##

- <https://highlightjs.org/download/>
- <https://highlightjs.readthedocs.io/en/latest/>

[&uarr;](#TOC)

## Changes ##

- 2019-06-10
  - Markdig.dll markdig.signed.0.17.0
  - Markdig pipeline configured with UseAutoIdentifiers(Github)
- 2019-02-14
  - Markdig.dll markdig.signed.0.15.7.0

[&uarr;](#TOC)
