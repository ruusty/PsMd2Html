# md2html <!-- omit in toc --> #

~~~plaintext
Version:        4.3.6415.8603
Date:           2017-05-15T23-53
~~~

- [Description](#description)
- [Powershell Usage](#powershell-usage)
  - [Example Usage](#example-usage)
    - [Module Commands](#module-commands)
    - [Get help](#get-help)
- [Cmd Usage](#cmd-usage)
- [Markdown Examples](#markdown-examples)
- [CommonMark](#commonmark)
- [Resources](#resources)
- [highlightjs](#highlightjs)
- [Changes](#changes)

## Description ##

md2html is a PowerShell module to automate converting Markdown files into html files.

Uses the __[Markdig](https://github.com/lunet-io/markdig)__ CommonMark compliant, extensible Markdown processor for .NET.

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
New-Alias -Name md2html -Value convert-Markdown2Html -Description "Converts Markdown documents to html"
md2html -verbose -recurse
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

## Cmd Usage ##

~~~dos
md2html
~~~

`md2html.bat` is installed by _Chocolatey_

~~~dos
@echo off
powershell -NoProfile -ExecutionPolicy unrestricted import-module -verbose 'D:\Users\Russell\.PowershellModules\OraclePlSqlInstaller'; convertto-mdhtml %* -verbose
~~~

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

## CommonMark ##

__[commonmark.org](http://commonmark.org)__ 

- Specification for __[CommonMark](http://spec.commonmark.org)__.
- CommonMark __[code](http://code.commonmark.org)__ on GitHub.
- The official __[dingus](http://try.commonmark.org)__ which allows people to experiment.

## Resources ##

- [mastering-markdown](https://guides.github.com/features/mastering-markdown)
- <https://www.nuget.org/packages/Markdig.Signed>
- <https://github.com/lunet-io/markdig>
- [Markdown Here Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Here-Cheatsheet)
- <https://github.com/gitlabhq/gitlabhq/blob/master/doc/user/markdown.md>
- <https://www.markdownguide.org/extended-syntax/>
- <http://www.tablesgenerator.com/markdown_tables>

## highlightjs ##

- <https://highlightjs.org/download/>
- <https://highlightjs.readthedocs.io/en/latest/>

## Changes ##

2019-02-14 Markdig.dll 0.15.7.0
