# Grid Tables #

<https://www.tablesgenerator.com/text_tables>

Grid-tables .

+----+-------------+-------+-------+--------+-------+
| No | Competition | John  | Adam  | Robert | Paul  |
+----+-------------+-------+-------+--------+-------+
| 1  | Swimming    |  1:30 |  2:05 |   1:15 |  1:41 |
+----+-------------+-------+-------+--------+-------+
| 2  | Running     | 15:30 | 14:10 |  15:45 | 16:00 |
+----+-------------+-------+-------+--------+-------+
| 3  | Shooting    |   70% |   55% |    90% |   88% |
+----+-------------+-------+-------+--------+-------+

<https://talk.commonmark.org/t/tables-in-pure-markdown/81/122>

| Item | Amount | Cost |
|:-----|-------:|-----:|
| Orange
| 10
| 7.00
|
| Bread 
| 4
| 3.00
|
| Butter
| 1
| 5.00
|
| Total |      | 15.00 |

| Server | IP | Description |
|--------|----|-------------|
| cl1 
| 192.168.100.1
| This is my first server in the list
|
| cl2 
| 10.10.1.22
| This is another one server
|
| windows-5BSD567DSLOS
| 127.0.0.12
| This is customer windows vm. dont touch this! 
|
| DFHSDDFFUCKENLONGNAME
| 192.168.1.50
| Some printer
|


| Server | IP | Description |
|--------|----|-------------|
| aaa | this is really long so I just   | ccc |
|     | continue down here              |     |
|.....|.................................|.....|
| aaa | bbb                             | ccc |
|.....|.................................|.....|
| this spans 2 (not 3) rows and 2 cols || ccc |
|                                      ||.....|
|                                      || ccc |
|.......................................|.....|
| aaa | bbb                             | ccc |
|.......................................|.....|
| aaa | - item one                      | ccc |
|     | - item two                      |     |


| heading |              heading 2              |
|         |      sub head a      |  sub head b  |
|=========|======================|==============|
| aaa     | this is still just   | ccc          |
|         | a single row but I   |              |
|         | talk too much        |              |
|---------|----------------------|--------------|
| aaa     | bbb                  | ccc          |
|---------|----------------------|--------------|
| this spans two rows and two    | ccc          |
| columns                        |--------------|
|                                | ccc          |
|---------|:--------------------:|--------------|
| aaa     |      centered        | ccc          |
|---------|----------------------|--------------|
| aaa     | - item one           | ccc          |
|         | - item two           |              |


 | | |
|-|-|-|
|__Bold Key__| Value1 |
| Normal Key | Value2 |

|-------------|--------|
|**Name:**    |John Doe|
|**Position:**|CEO     |