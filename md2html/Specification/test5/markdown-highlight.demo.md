# Markdown Highlight Examples <!-- omit in toc --> #


- [sql](#sql)
- [plaintext](#plaintext)
- [dos, bat](#dos-bat)
- [console](#console)
- [powershell](#powershell)
- [bash](#bash)
        - [CONFIG](#config)
- [ini](#ini)
- [json](#json)
- [C#](#c)
- [markdown](#markdown)
- [Nginx](#nginx)
- [HTML, XML](#html-xml)
- [shell, console](#shell-console)
- [javascript](#javascript)

Hightlight Library <https://highlightjs.org/static/demo/>

## sql ##

```sql
select name, column from dba_cols;

CREATE TABLE "topic" (
    "id" serial NOT NULL PRIMARY KEY,
    "forum_id" integer NOT NULL,
    "subject" varchar(255) NOT NULL
);
ALTER TABLE "topic"
ADD CONSTRAINT forum_id FOREIGN KEY ("forum_id")
REFERENCES "forum" ("id");
```

## plaintext ##

~~~plaintext
Just plan old tty text
~~~

## dos, bat   ##

~~~dos
cd \
copy a b
ping 192.168.0.1
@rem ping 192.168.0.1
net stop sharedaccess
del %tmp% /f /s /q
del %temp% /f /s /q
ipconfig /flushdns
taskkill /F /IM JAVA.EXE /T
~~~

~~~bat
cd \
copy a b
ping 192.168.0.1
@rem ping 192.168.0.1
net stop sharedaccess
del %tmp% /f /s /q
del %temp% /f /s /q
ipconfig /flushdns
taskkill /F /IM JAVA.EXE /T
~~~

## console ##

~~~console
dir *.txt
~~~

## powershell ##

~~~powershell
convert-Markdown2Html -path "*.md",'README*.md',"..\Specification\*.md","..\Specification\*.md" -verbose -WhatIf

$initialDate = [datetime]'2013/1/8'

$rollingDate = $initialDate

do {
    $client = New-Object System.Net.WebClient
    $results = $client.DownloadString("http://not.a.real.url")
    Write-Host "$rollingDate.ToShortDateString() - $results"
    $rollingDate = $rollingDate.AddDays(21)
    $username = [System.Environment]::UserName
} until ($rollingDate -ge [datetime]'2013/12/31') 
~~~

## bash ##

~~~bash
#!/bin/bash

###### CONFIG
ACCEPTED_HOSTS="/root/.hag_accepted.conf"
BE_VERBOSE=false

if [ "$UID" -ne 0 ]
then
 echo "Superuser rights required"
 exit 2
fi

genApacheConf(){
 echo -e "# Host ${HOME_DIR}$1/$2 :"
}
~~~

## ini ##

```ini
; boilerplate
[package]
name = "some_name"
authors = ["Author"]
description = "This is \
a description"

[[lib]]
name = ${NAME}
default = True
auto = no
counter = 1_000
```

## json ##

```json
[
  {
    "title": "apples",
    "count": [12000, 20000],
    "description": {"text": "...", "sensitive": false}
  },
  {
    "title": "oranges",
    "count": [17500, null],
    "description": {"text": "...", "sensitive": false}
  }
]
```

## C#  ##

```C#
using System.IO.Compression;

#pragma warning disable 414, 3021

namespace MyApplication
{
    [Obsolete("...")]
    class Program : IInterface
    {
        public static List<int> JustDoIt(int count)
        {
            Console.WriteLine($"Hello {Name}!");
            return new List<int>(new int[] { 1, 2, 3 })
        }
    }
}
```

## markdown ##

```markdown
# hello world

you can write text [with links](http://example.com) inline or [link references][1].

* one _thing_ has *em*phasis
* two __things__ are **bold**

[1]: http://example.com

---

hello world
===========

<this_is inline="xml"></this_is>

> markdown is so cool

    so are code segments

1. one thing (yeah!)
2. two thing `i can write code`, and `more` wipee!
```

## Nginx ##

```Nginx
ser  www www;
worker_processes  2;
pid /var/run/nginx.pid;
error_log  /var/log/nginx.error_log  debug | info | notice | warn | error | crit;

events {
    connections   2000;
    use kqueue | rtsig | epoll | /dev/poll | select | poll;
}

http {
    log_format main      '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $bytes_sent '
                         '"$http_referer" "$http_user_agent" '
                         '"$gzip_ratio"';

    send_timeout 3m;
    client_header_buffer_size 1k;

    gzip on;
    gzip_min_length 1100;

    #lingering_time 30;

    server {
        server_name   one.example.com  www.one.example.com;
        access_log   /var/log/nginx.access_log  main;

        rewrite (.*) /index.php?page=$1 break;

        location / {
            proxy_pass         http://127.0.0.1/;
            proxy_redirect     off;
            proxy_set_header   Host             $host;
            proxy_set_header   X-Real-IP        $remote_addr;
            charset            koi8-r;
        }

        location /api/ {
            fastcgi_pass 127.0.0.1:9000;
        }

        location ~* \.(jpg|jpeg|gif)$ {
            root         /spool/www;
        }
    }
}
```

## HTML, XML ##

```xml
<!DOCTYPE html>
<title>Title</title>

<style>body {width: 500px;}</style>

<script type="application/javascript">
  function $init() {return true;}
</script>

<body>
  <p checked class="title" id='title'>Title</p>
  <!-- here goes the rest of the page -->
```

```HTML
<!DOCTYPE html>
<title>Title</title>

<style>body {width: 500px;}</style>

<script type="application/javascript">
  function $init() {return true;}
</script>

<body>
  <p checked class="title" id='title'>Title</p>
  <!-- here goes the rest of the page -->
```

## shell, console ##

```shell
$ echo $EDITOR
vim
$ git checkout master
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.
$ git push
Everything up-to-date
$ echo 'All
> done!'
All
done!
```

```console
$ echo $EDITOR
vim
$ git checkout master
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.
$ git push
Everything up-to-date
$ echo 'All
> done!'
All
done!
```

## javascript ##

```javascript
function $initHighlight(block, cls) {
  try {
    if (cls.search(/\bno\-highlight\b/) != -1)
      return process(block, true, 0x0F) +
             ` class="${cls}"`;
  } catch (e) {
    /* handle exception */
  }
  for (var i = 0 / 2; i < classes.length; i++) {
    if (checkCondition(classes[i]) === undefined)
      console.log('undefined');
  }
}

export  $initHighlight;
```

