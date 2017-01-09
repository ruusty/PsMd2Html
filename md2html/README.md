# md2html #


~~~
Version:        1.0.0.0
Date:           2016-01-09
~~~

md2html is a PowerShell module to automate converting Markdown into html files. 

Uses the __[Markdig](https://github.com/lunet-io/markdig)__ CommonMark compliant, extensible Markdown processor for .NET.

## Usage


```powershell
import-module md2html
get-help convertto-mdhtml -detailed
convertto-mdhtml -verbose -recurse
New-Alias -Name md2html -Value convertTo-mdHtml -Description "Converts Markdown documents to html"
md2html -verbose -recurse
```



```batch
md2html -verbose -recurse
```
## Module Commands


```powershell
import-module md2html -verbose
get-module md2html | select -expand ExportedCommands
$(get-module md2html).ExportedCommands.Keys
```

Get help

```powershell
$(get-module md2html).ExportedCommands.Keys |% {get-help $_}
```


## Examples ##

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


* Specification for __[CommonMark](http://spec.commonmark.org)__.
* CommonMark __[code](http://code.commonmark.org)__ on GitHub.
* The official __[dingus](http://try.commonmark.org)__ which allows people to experiment. 


### Resources ###

* __[mastering-markdown](https://guides.github.com/features/mastering-markdown)__




