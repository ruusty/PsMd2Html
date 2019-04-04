# !Readme.test1.md #

*[HTML]: Hyper Text Markup Language
*[W3C]:  World Wide Web Consortium

## Tables ##

First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell


| Function name | Description                    |
| ------------- | ------------------------------ |
| `help()`      | Display the help window.       |
| `destroy()`   | **Destroy your computer!**     |

Definition Lists

Apple
:   Pomaceous fruit of plants of the genus Malus in
    the family Rosaceae.

Orange
:   The fruit of an evergreen tree of th

## Fenced Code Blocks ##

This is a paragraph introducing:

~~~~~~~~~~~~~~~~~~~~~
a one-line code block
~~~~~~~~~~~~~~~~~~~~~


``````````````````
another code block
``````````````````

~~~

blank line before
blank line after

~~~


## Markdown Inside HTML Blocks ##

<div markdown="1">
This is *true* markdown text.
</div>

<table>
<tr>
<td markdown="1">This is *true* markdown text.</td>
</tr>
</table>

Header 1            {#header1}
========

## Header 2 ##      {#header2}

[Link back to header 1](#header1)

To add a class name, which can be used as a hook for a style sheet, use a dot like this:

## The Site ##    {.main}

The id and multiple class names can be combined by putting them all into the same special attribute block:

## The Site ##    {.main .shine #the-site}


[link][linkref] or [linkref]
![img][linkref]

[linkref]: url "optional title" {#id .class}


Strikethrough

GFM adds syntax to strikethrough text, which is missing from standard Markdown.

~~Mistaken text.~~

Fenced code blocks

Standard Markdown converts text with four spaces at the beginning of each line into a code block; GFM also supports fenced blocks. Just wrap your code in ``` (as shown below) and you won't need to indent it by four spaces. Note that although fenced code blocks don't need to be preceded by a blank line—unlike indented code blocks—we recommend placing a blank line before them to make the raw Markdown easier to read.

Here's an example:

```
function test() {
  console.log("notice the blank line before this function?");
}
```

## Task Lists ##

Further, lists can be turned into Task Lists by prefacing list items with [ ] or [x] (incomplete or complete, respectively).

- [x] @mentions, #refs, [links](), **formatting**, and <del>tags</del> supported
- [x] list syntax required (any unordered or ordered list supported)
- [x] this is a complete item
- [ ] this is an incomplete item


Roses are red

Violets are blue

~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.html #example-1}
<p>paragraph <b>emphasis</b>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~


| Item      | Value |
| --------- | -----:|
| Computer  | $1600 |
| Phone     |   $12 |
| Pipe      |    $1 |