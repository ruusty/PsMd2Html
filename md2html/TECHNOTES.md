# md2html <!-- omit in toc --> #

~~~text
Project:        GIS/OMS
Product:        md2html
Version:        4.3.00.00
Date:           2019-06-10
Description:    md2html Tech notes
~~~

<a name="TOC"></a>


- [Description](#description)

## Description ##

~~~powershell
md2html\Convert-Markdown2Html -path $ProjBuildPath -recurse -verbose
~~~

- Need to support this in build scripts

~~~powershell
import-module -verbose:$verbose md2html; convertto-mdhtml -verbose:$verbose  -recurse
~~~

[&uarr;](#TOC)