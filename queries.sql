/* BEGIN SMALL TEST QUERIES */

.timer ON

CREATE TABLE a(a INTEGER, b INTEGER, c INTEGER);
CREATE TABLE b(a INTEGER, b INTEGER, c INTEGER);
CREATE TABLE c(a INTEGER, b INTEGER, c INTEGER);

INSERT INTO a VALUES(1, 1, 1);
INSERT INTO a VALUES(2, 1, 1);

INSERT INTO b VALUES(1, 1, 2);
INSERT INTO b VALUES(2, 1, 2);

INSERT INTO c VALUES(2, 1, 1);
INSERT INTO c VALUES(2, 3, 1);
INSERT INTO c VALUES(2, 1, 2);

SELECT * FROM c LEFT OUTER JOIN (
  SELECT b.a AS a, b.b AS b FROM b LEFT OUTER JOIN a ON b.a = a.a AND b.b = a.b
) AS r ON c.a = r.a;

/* END SMALL TEST QUERIES */

/* BEGIN BENCHMARK QUERIES */

/* 1a

SELECT MIN(r2.note) AS production_note,
       MIN(t.title) AS movie_title,
       MIN(t.production_year) AS movie_year
FROM title as t LEFT OUTER JOIN (
  SELECT mi_idx.movie_id AS movie_id, r2.note AS note FROM movie_info_idx AS mi_idx LEFT OUTER JOIN (
    SELECT * FROM movie_companies AS mc LEFT OUTER JOIN (

    ) AS r3 ON 
  ) AS r2 ON mi_idx.info_type_id = r2.id AND mi_idx.movie_id = r2.movie_id
) AS r1 ON t.id = r1.movie_id;
*/

SELECT COUNT(c.title_id) FROM crew AS c LEFT OUTER JOIN (
  SELECT c.title_id AS title_id, r4.second_person AS second_person FROM crew AS c LEFT OUTER JOIN (
    SELECT r3.title_id AS title_id, r3.person_id AS person_id, r3.second_person AS second_person FROM people AS p LEFT OUTER JOIN (
      SELECT c.person_id AS second_person, r2.premiered AS premiered, r2.title_id AS title_id, r2.person_id AS person_id FROM crew AS c LEFT OUTER JOIN (
        SELECT r1.title_id AS title_id, r1.premiered AS premiered, p.person_id AS person_id FROM people AS p LEFT OUTER JOIN (
          SELECT t.premiered AS premiered, c.title_id AS title_id, c.person_id AS person_id FROM titles AS t INNER JOIN crew AS c ON t.title_id = c.title_id
        ) AS r1 ON p.person_id = r1.person_id WHERE p.died < r1.premiered
      ) AS r2 ON c.title_id = r2.title_id AND c.person_id < r2.person_id
    ) AS r3 ON p.person_id = r3.second_person WHERE p.died < r3.premiered
  ) AS r4 ON c.title_id < r4.title_id AND c.person_id = r4.person_id
) AS r5 ON c.title_id = r5.title_id AND c.person_id = r5.second_person;
/*
29495468
Run Time: real 317.952 user 185.444579 sys 131.673259
Run Time: real 301.067 user 182.245922 sys 118.074207
Run Time: real 302.686 user 183.871701 sys 118.108017
*/
SELECT COUNT(c.title_id) FROM crew AS c INNER JOIN (
  SELECT c.title_id AS title_id, r4.second_person AS second_person FROM crew AS c INNER JOIN (
    SELECT r3.title_id AS title_id, r3.person_id AS person_id, r3.second_person AS second_person FROM people AS p INNER JOIN (
      SELECT c.person_id AS second_person, r2.premiered AS premiered, r2.title_id AS title_id, r2.person_id AS person_id FROM crew AS c INNER JOIN (
        SELECT r1.title_id AS title_id, r1.premiered AS premiered, p.person_id AS person_id FROM people AS p INNER JOIN (
          SELECT t.premiered AS premiered, c.title_id AS title_id, c.person_id AS person_id FROM titles AS t INNER JOIN crew AS c ON t.title_id = c.title_id
        ) AS r1 ON p.person_id = r1.person_id WHERE p.died < r1.premiered
      ) AS r2 ON c.title_id = r2.title_id AND c.person_id < r2.person_id
    ) AS r3 ON p.person_id = r3.second_person WHERE p.died < r3.premiered
  ) AS r4 ON c.title_id < r4.title_id AND c.person_id = r4.person_id
) AS r5 ON c.title_id = r5.title_id AND c.person_id = r5.second_person;
/*
29495468
Run Time: real 452.911 user 261.760857 sys 190.045020
Run Time: real 442.354 user 253.558389 sys 187.768525
Run Time: real 444.671 user 254.469738 sys 189.118673
*/
/*
addr  opcode         p1    p2    p3    p4             p5  comment      
----  -------------  ----  ----  ----  -------------  --  -------------
0     Init           0     124   0                    0   Start at 124
1     Goto           0     93    0                    0   
2       Once           0     92    0                    0   materialize r5
3       Goto           0     60    0                    0   
4         Once           0     59    0                    0   materialize r4
5         OpenEphemeral  3     3     0                    0   nColumn=3
6         OpenRead       10    4     0     6              0   root=4 iDb=0; titles
7         OpenRead       11    7     0     2              0   root=7 iDb=0; crew
8         OpenRead       12    3088119 0     k(2,,)         2   root=3088119 iDb=0; ix_crew_title_id
9         OpenRead       8     2     0     4              0   root=2 iDb=0; people
10        OpenRead       13    2161895 0     k(2,,)         2   root=2161895 iDb=0; ix_people_person_id
11        OpenRead       6     7     0     2              0   root=7 iDb=0; crew
12        OpenRead       14    3088119 0     k(2,,)         2   root=3088119 iDb=0; ix_crew_title_id
13        OpenRead       4     2     0     4              0   root=2 iDb=0; people
14        OpenRead       15    2161895 0     k(2,,)         2   root=2161895 iDb=0; ix_people_person_id
15        Rewind         10    59    0                    0   
16          Column         10    0     3                    0   r[3]= cursor 10 column 0
17          IsNull         3     58    0                    0   if r[3]==NULL goto 58
18          SeekGE         12    58    3     1              0   key=r[3]
19            IdxGT          12    58    3     1              0   key=r[3]
20            DeferredSeek   12    0     11                   0   Move 11 to 12.rowid if needed
21            Column         11    1     4                    0   r[4]= cursor 11 column 1
22            IsNull         4     57    0                    0   if r[4]==NULL goto 57
23            SeekGE         13    57    4     1              0   key=r[4]
24              IdxGT          13    57    4     1              0   key=r[4]
25              DeferredSeek   13    0     8                    0   Move 8 to 13.rowid if needed
26              Column         8     3     5                    0   r[5]= cursor 8 column 3
27              Column         10    5     6                    0   r[6]= cursor 10 column 5
28              Ge             6     56    5     BINARY-8       83  if r[5]>=r[6] goto 56
29              Column         12    0     7                    0   r[7]= cursor 12 column 0
30              IsNull         7     56    0                    0   if r[7]==NULL goto 56
31              SeekGE         14    56    7     1              0   key=r[7]
32                IdxGT          14    56    7     1              0   key=r[7]
33                DeferredSeek   14    0     6                    0   Move 6 to 14.rowid if needed
34                Column         14    0     6                    0   r[6]= cursor 14 column 0
35                Column         12    0     5                    0   r[5]= cursor 12 column 0
36                Ne             5     55    6     BINARY-8       81  if r[6]!=r[5] goto 55
37                Column         6     1     5                    0   r[5]= cursor 6 column 1
38                Column         13    0     6                    0   r[6]= cursor 13 column 0
39                Ge             6     55    5     BINARY-8       81  if r[5]>=r[6] goto 55
40                Column         6     1     8                    0   r[8]= cursor 6 column 1
41                IsNull         8     55    0                    0   if r[8]==NULL goto 55
42                SeekGE         15    55    8     1              0   key=r[8]
43                  IdxGT          15    55    8     1              0   key=r[8]
44                  DeferredSeek   15    0     4                    0   Move 4 to 15.rowid if needed
45                  Column         4     3     6                    0   r[6]= cursor 4 column 3
46                  Column         10    5     5                    0   r[5]= cursor 10 column 5
47                  Ge             5     54    6     BINARY-8       83  if r[6]>=r[5] goto 54
48                  Column         12    0     9                    0   r[9]= cursor 12 column 0
49                  Column         13    0     10                   0   r[10]= cursor 13 column 0
50                  Column         6     1     11                   0   r[11]= cursor 6 column 1
51                  MakeRecord     9     3     5                    0   r[5]=mkrec(r[9..11])
52                  NewRowid       3     6     0                    0   r[6]=rowid
53                  Insert         3     5     6                    8   intkey=r[6] data=r[5]
54                Next           15    43    1                    0   
55              Next           14    32    1                    0   
56            Next           13    24    1                    0   
57          Next           12    19    1                    0   
58        Next           10    16    0                    1   
59      Return         2     4     0                    0   end r4
60      OpenEphemeral  1     2     0                    0   nColumn=2
61      OpenRead       2     7     0     2              0   root=7 iDb=0; crew
62      Rewind         2     92    0                    0   
63        Once           0     65    0                    0   
64        Gosub          2     4     0                    0   
65        Once           0     75    0                    0   
66        OpenAutoindex  16    4     0     k(4,B,,,)      0   nColumn=4; for r4
67        Rewind         3     75    0                    0   
68          Column         3     1     13                   0   r[13]= cursor 3 column 1
69          Column         3     0     14                   0   r[14]= cursor 3 column 0
70          Column         3     2     15                   0   r[15]= cursor 3 column 2
71          Rowid          3     16    0                    0   r[16]=r4.rowid
72          MakeRecord     13    4     12                   0   r[12]=mkrec(r[13..16])
73          IdxInsert      16    12    0                    16  key=r[12]
74        Next           3     68    0                    3   
75        Integer        0     17    0                    0   r[17]=0; init LEFT JOIN no-match flag
76        Column         2     1     18                   0   r[18]= cursor 2 column 1
77        IsNull         18    91    0                    0   if r[18]==NULL goto 91
78        SeekGE         16    91    18    1              0   key=r[18]
79          IdxGT          16    91    18    1              0   key=r[18]
80          Column         2     0     12                   0   r[12]= cursor 2 column 0
81          Column         16    1     19                   0   r[19]= cursor 16 column 1
82          Ge             19    89    12    BINARY-8       81  if r[12]>=r[19] goto 89
83          Integer        1     17    0                    0   r[17]=1; record LEFT JOIN hit
84          Column         2     0     20                   0   r[20]= cursor 2 column 0
85          Column         16    2     21                   0   r[21]= cursor 16 column 2
86          MakeRecord     20    2     19                   0   r[19]=mkrec(r[20..21])
87          NewRowid       1     12    0                    0   r[12]=rowid
88          Insert         1     19    12                   8   intkey=r[12] data=r[19]
89        Next           16    79    0                    0   
90        IfPos          17    91    0                    0   if r[17]>0 then r[17]-=0, goto 91
91      Next           2     63    0                    1   
92    Return         1     2     0                    0   end r5
93    Null           0     22    23                   0   r[22..23]=NULL
94    OpenRead       0     7     0     2              0   root=7 iDb=0; crew
95    Rewind         0     120   0                    0   
96      Once           0     98    0                    0   
97      Gosub          1     2     0                    0   
98      Once           0     107   0                    0   
99      OpenAutoindex  17    3     0     k(3,B,B,)      0   nColumn=3; for r5
100     Rewind         1     107   0                    0   
101       Column         1     1     25                   0   r[25]= cursor 1 column 1
102       Column         1     0     26                   0   r[26]= cursor 1 column 0
103       Rowid          1     27    0                    0   r[27]=r5.rowid
104       MakeRecord     25    3     24                   0   r[24]=mkrec(r[25..27])
105       IdxInsert      17    24    0                    16  key=r[24]
106     Next           1     101   0                    3   
107     Integer        0     28    0                    0   r[28]=0; init LEFT JOIN no-match flag
108     Column         0     1     29                   0   r[29]= cursor 0 column 1
109     IsNull         29    119   0                    0   if r[29]==NULL goto 119
110     Column         0     0     30                   0   r[30]= cursor 0 column 0
111     IsNull         30    119   0                    0   if r[30]==NULL goto 119
112     SeekGE         17    119   29    2              0   key=r[29..30]
113       IdxGT          17    119   29    2              0   key=r[29..30]
114       Integer        1     28    0                    0   r[28]=1; record LEFT JOIN hit
115       Column         0     0     24                   0   r[24]= cursor 0 column 0
116       AggStep        0     24    23    count(1)       1   accum=r[23] step(r[24])
117     Next           17    113   0                    0   
118     IfPos          28    119   0                    0   if r[28]>0 then r[28]-=0, goto 119
119   Next           0     96    0                    1   
120   AggFinal       23    1     0     count(1)       0   accum=r[23] N=1
121   Copy           23    31    0                    0   r[31]=r[23]
122   ResultRow      31    1     0                    0   output=r[31]
123   Halt           0     0     0                    0   
124   Transaction    0     0     19    0              1   usesStmtJournal=0
125   Goto           0     1     0                    0 

For INNER JOIN

addr  opcode         p1    p2    p3    p4             p5  comment      
----  -------------  ----  ----  ----  -------------  --  -------------
0     Init           0     86    0                    0   Start at 86
1     Null           0     1     2                    0   r[1..2]=NULL
2     OpenRead       10    4     0     6              0   root=4 iDb=0; titles
3     OpenRead       6     7     0     2              0   root=7 iDb=0; crew
4     OpenRead       12    3088119 0     k(2,,)         2   root=3088119 iDb=0; ix_crew_title_id
5     OpenRead       4     2     0     4              0   root=2 iDb=0; people
6     OpenRead       13    2161895 0     k(2,,)         2   root=2161895 iDb=0; ix_people_person_id
7     OpenRead       11    7     0     2              0   root=7 iDb=0; crew
8     OpenRead       14    3088119 0     k(2,,)         2   root=3088119 iDb=0; ix_crew_title_id
9     OpenRead       8     2     0     4              0   root=2 iDb=0; people
10    OpenRead       15    2161895 0     k(2,,)         2   root=2161895 iDb=0; ix_people_person_id
11    OpenRead       0     7     0     2              0   root=7 iDb=0; crew
12    OpenRead       16    3493029 0     k(2,,)         2   root=3493029 iDb=0; ix_crew_person_id
13    OpenRead       2     7     0     2              0   root=7 iDb=0; crew
14    OpenRead       17    3088119 0     k(2,,)         2   root=3088119 iDb=0; ix_crew_title_id
15    Rewind         10    82    0                    0   
16      Column         10    0     3                    0   r[3]= cursor 10 column 0
17      IsNull         3     81    0                    0   if r[3]==NULL goto 81
18      SeekGE         12    81    3     1              0   key=r[3]
19        IdxGT          12    81    3     1              0   key=r[3]
20        DeferredSeek   12    0     6                    0   Move 6 to 12.rowid if needed
21        Column         12    0     4                    0   r[4]= cursor 12 column 0
22        Column         10    0     5                    0   r[5]= cursor 10 column 0
23        Ne             5     80    4     BINARY-8       81  if r[4]!=r[5] goto 80
24        Column         6     1     6                    0   r[6]= cursor 6 column 1
25        IsNull         6     80    0                    0   if r[6]==NULL goto 80
26        SeekGE         13    80    6     1              0   key=r[6]
27          IdxGT          13    80    6     1              0   key=r[6]
28          DeferredSeek   13    0     4                    0   Move 4 to 13.rowid if needed
29          Column         13    0     5                    0   r[5]= cursor 13 column 0
30          Column         6     1     4                    0   r[4]= cursor 6 column 1
31          Ne             4     79    5     BINARY-8       81  if r[5]!=r[4] goto 79
32          Column         4     3     4                    0   r[4]= cursor 4 column 3
33          Column         10    5     5                    0   r[5]= cursor 10 column 5
34          Ge             5     79    4     BINARY-8       83  if r[4]>=r[5] goto 79
35          Column         12    0     7                    0   r[7]= cursor 12 column 0
36          IsNull         7     79    0                    0   if r[7]==NULL goto 79
37          SeekGE         14    79    7     1              0   key=r[7]
38            IdxGT          14    79    7     1              0   key=r[7]
39            DeferredSeek   14    0     11                   0   Move 11 to 14.rowid if needed
40            Column         10    0     5                    0   r[5]= cursor 10 column 0
41            Column         14    0     4                    0   r[4]= cursor 14 column 0
42            Ne             4     78    5     BINARY-8       81  if r[5]!=r[4] goto 78
43            Column         11    1     8                    0   r[8]= cursor 11 column 1
44            IsNull         8     78    0                    0   if r[8]==NULL goto 78
45            SeekGE         15    78    8     1              0   key=r[8]
46              IdxGT          15    78    8     1              0   key=r[8]
47              DeferredSeek   15    0     8                    0   Move 8 to 15.rowid if needed
48              Column         6     1     4                    0   r[4]= cursor 6 column 1
49              Column         15    0     5                    0   r[5]= cursor 15 column 0
50              Ge             5     77    4     BINARY-8       81  if r[4]>=r[5] goto 77
51              Column         8     3     5                    0   r[5]= cursor 8 column 3
52              Column         10    5     4                    0   r[4]= cursor 10 column 5
53              Ge             4     77    5     BINARY-8       83  if r[5]>=r[4] goto 77
54              Column         6     1     9                    0   r[9]= cursor 6 column 1
55              IsNull         9     77    0                    0   if r[9]==NULL goto 77
56              SeekGE         16    77    9     1              0   key=r[9]
57                IdxGT          16    77    9     1              0   key=r[9]
58                DeferredSeek   16    0     0                    0   Move 0 to 16.rowid if needed
59                Column         16    0     4                    0   r[4]= cursor 16 column 0
60                Column         6     1     5                    0   r[5]= cursor 6 column 1
61                Ne             5     76    4     BINARY-8       81  if r[4]!=r[5] goto 76
62                Column         0     0     10                   0   r[10]= cursor 0 column 0
63                IsNull         10    76    0                    0   if r[10]==NULL goto 76
64                SeekGE         17    76    10    1              0   key=r[10]
65                  IdxGT          17    76    10    1              0   key=r[10]
66                  DeferredSeek   17    0     2                    0   Move 2 to 17.rowid if needed
67                  Column         17    0     5                    0   r[5]= cursor 17 column 0
68                  Column         14    0     4                    0   r[4]= cursor 14 column 0
69                  Ge             4     75    5     BINARY-8       81  if r[5]>=r[4] goto 75
70                  Column         2     1     4                    0   r[4]= cursor 2 column 1
71                  Column         15    0     5                    0   r[5]= cursor 15 column 0
72                  Ne             5     75    4     BINARY-8       81  if r[4]!=r[5] goto 75
73                  Column         0     0     5                    0   r[5]= cursor 0 column 0
74                  AggStep        0     5     2     count(1)       1   accum=r[2] step(r[5])
75                Next           17    65    1                    0   
76              Next           16    57    1                    0   
77            Next           15    46    1                    0   
78          Next           14    38    1                    0   
79        Next           13    27    1                    0   
80      Next           12    19    1                    0   
81    Next           10    16    0                    1   
82    AggFinal       2     1     0     count(1)       0   accum=r[2] N=1
83    Copy           2     11    0                    0   r[11]=r[2]
84    ResultRow      11    1     0                    0   output=r[11]
85    Halt           0     0     0                    0   
86    Transaction    0     0     19    0              1   usesStmtJournal=0
87    Goto           0     1     0                    0
*/

SELECT COUNT(c.title_id) FROM crew AS c LEFT OUTER JOIN (
  SELECT c.title_id AS title_id, r4.second_person AS second_person FROM crew AS c LEFT OUTER JOIN (
    SELECT r3.title_id AS title_id, r3.person_id AS person_id, r3.second_person AS second_person FROM people AS p LEFT OUTER JOIN (
      SELECT c.person_id AS second_person, r2.premiered AS premiered, r2.title_id AS title_id, r2.person_id AS person_id FROM crew AS c LEFT OUTER JOIN (
        SELECT r1.title_id AS title_id, r1.premiered AS premiered, p.person_id AS person_id FROM people AS p LEFT OUTER JOIN (
          SELECT t.premiered AS premiered, c.title_id AS title_id, c.person_id AS person_id FROM titles AS t INNER JOIN crew AS c ON t.title_id = c.title_id
        ) AS r1 ON p.person_id = r1.person_id WHERE p.died < r1.premiered
      ) AS r2 ON c.title_id = r2.title_id AND c.person_id != r2.person_id
    ) AS r3 ON p.person_id = r3.second_person WHERE p.died <= r3.premiered
  ) AS r4 ON c.title_id != r4.title_id AND c.person_id = r4.person_id
) AS r5 ON c.title_id = r5.title_id AND c.person_id = r5.second_person;
/*
132293052
Run Time: real 590.123 user 363.510000 sys 225.238916
*/
SELECT COUNT(c.title_id) FROM crew AS c INNER JOIN (
  SELECT c.title_id AS title_id, r4.second_person AS second_person FROM crew AS c INNER JOIN (
    SELECT r3.title_id AS title_id, r3.person_id AS person_id, r3.second_person AS second_person FROM people AS p INNER JOIN (
      SELECT c.person_id AS second_person, r2.premiered AS premiered, r2.title_id AS title_id, r2.person_id AS person_id FROM crew AS c INNER JOIN (
        SELECT r1.title_id AS title_id, r1.premiered AS premiered, p.person_id AS person_id FROM people AS p INNER JOIN (
          SELECT t.premiered AS premiered, c.title_id AS title_id, c.person_id AS person_id FROM titles AS t INNER JOIN crew AS c ON t.title_id = c.title_id
        ) AS r1 ON p.person_id = r1.person_id WHERE p.died < r1.premiered
      ) AS r2 ON c.title_id = r2.title_id AND c.person_id != r2.person_id
    ) AS r3 ON p.person_id = r3.second_person WHERE p.died <= r3.premiered
  ) AS r4 ON c.title_id != r4.title_id AND c.person_id = r4.person_id
) AS r5 ON c.title_id = r5.title_id AND c.person_id = r5.second_person;
/*
132293052
Run Time: real 738.733 user 432.403519 sys 304.251479
*/

SELECT COUNT(r3.title_id) FROM people AS p LEFT OUTER JOIN (
  SELECT c.person_id AS second_person, r2.premiered AS premiered, r2.title_id AS title_id FROM crew AS c LEFT OUTER JOIN (
    SELECT r1.title_id AS title_id, r1.premiered AS premiered, p.person_id AS person_id FROM people AS p LEFT OUTER JOIN (
      SELECT t.premiered AS premiered, c.title_id AS title_id, c.person_id AS person_id FROM titles AS t INNER JOIN crew AS c ON t.title_id = c.title_id
    ) AS r1 ON p.person_id = r1.person_id WHERE p.died < r1.premiered
  ) AS r2 ON c.title_id = r2.title_id AND c.person_id != r2.person_id
) AS r3 ON p.person_id = r3.second_person WHERE p.died <= r3.premiered;
/*
247684
Run Time: real 174.498 user 77.650653 sys 96.426751
*/
SELECT COUNT(r3.title_id) FROM people AS p INNER JOIN (
  SELECT c.person_id AS second_person, r2.premiered AS premiered, r2.title_id AS title_id FROM crew AS c INNER JOIN (
    SELECT r1.title_id AS title_id, r1.premiered AS premiered, p.person_id AS person_id FROM people AS p INNER JOIN (
      SELECT t.premiered AS premiered, c.title_id AS title_id, c.person_id AS person_id FROM titles AS t INNER JOIN crew AS c ON t.title_id = c.title_id
    ) AS r1 ON p.person_id = r1.person_id WHERE p.died < r1.premiered
  ) AS r2 ON c.title_id = r2.title_id AND c.person_id != r2.person_id
) AS r3 ON p.person_id = r3.second_person WHERE p.died <= r3.premiered;
/*
247684
Run Time: real 173.062 user 77.310694 sys 95.290812
*/

SELECT COUNT(r2.title_id) FROM people AS p LEFT OUTER JOIN (
  SELECT r1.title_id AS title_id, r1.premiered AS premiered, p.person_id AS person_id FROM people AS p LEFT OUTER JOIN (
    SELECT t.premiered AS premiered, c.title_id AS title_id, c.person_id AS person_id FROM titles AS t INNER JOIN crew AS c ON t.title_id = c.title_id
  ) AS r1 ON p.person_id = r1.person_id WHERE p.died < r1.premiered
) AS r2 ON p.person_id != r2.person_id WHERE p.died <= r2.premiered;
/*

*/
SELECT COUNT(r2.title_id) FROM people AS p INNER JOIN (
  SELECT r1.title_id AS title_id, r1.premiered AS premiered, p.person_id AS person_id FROM people AS p INNER JOIN (
    SELECT t.premiered AS premiered, c.title_id AS title_id, c.person_id AS person_id FROM titles AS t INNER JOIN crew AS c ON t.title_id = c.title_id
  ) AS r1 ON p.person_id = r1.person_id WHERE p.died < r1.premiered
) AS r2 ON p.person_id != r2.person_id WHERE p.died <= r2.premiered;
/*

*/

SELECT COUNT(r1.title_id) FROM people AS p LEFT OUTER JOIN (
  SELECT t.premiered AS premiered, c.title_id AS title_id, c.person_id AS person_id FROM titles AS t INNER JOIN crew AS c ON t.title_id = c.title_id
) AS r1 ON p.person_id = r1.person_id WHERE p.died <= r1.premiered;
/*
370605
Run Time: real 158.204 user 71.928867 sys 85.896661
Run Time: real 166.203 user 73.036977 sys 92.706896
*/
SELECT COUNT(r1.title_id) FROM people AS p INNER JOIN (
  SELECT t.premiered AS premiered, c.title_id AS title_id, c.person_id AS person_id FROM titles AS t INNER JOIN crew AS c ON t.title_id = c.title_id
) AS r1 ON p.person_id = r1.person_id WHERE p.died <= r1.premiered;
/*
370605
Run Time: real 160.834 user 74.719162 sys 85.694244
Run Time: real 166.178 user 73.210529 sys 92.570072
*/


SELECT COUNT(*) FROM ratings AS r LEFT OUTER JOIN (
  SELECT r1.title_id FROM people AS p LEFT OUTER JOIN (
    SELECT t.premiered AS premiered, c.title_id AS title_id, c.person_id AS person_id FROM titles AS t INNER JOIN crew AS c ON t.title_id = c.title_id
  ) AS r1 ON p.person_id = r1.person_id WHERE p.died <= r1.premiered
) AS r2 ON r.title_id = r2.title_id WHERE r.rating < 3 AND r.votes > 100;
/*
6740
Run Time: real 231.393 user 106.554702 sys 124.270773
*/


SELECT COUNT(*) FROM people AS p LEFT OUTER JOIN (
  SELECT c.title_id AS title_id, c.person_id AS person_id FROM titles AS t INNER JOIN crew AS c ON t.title_id = c.title_id
) AS r1 ON p.person_id = r1.person_id WHERE p.born < 1950;

/*
12116502
Run Time: real 188.301 user 89.449953 sys 98.363583
Run Time: real 190.031 user 91.172836 sys 98.418515
*/

SELECT COUNT(*) FROM people AS p INNER JOIN (
  SELECT c.title_id AS title_id, c.person_id AS person_id FROM titles AS t INNER JOIN crew AS c ON t.title_id = c.title_id
) AS r1 ON p.person_id = r1.person_id WHERE p.born < 1950;

/*
12116502
Run Time: real 154.978 user 74.685208 sys 79.830978
Run Time: real 154.760 user 73.233496 sys 81.110178
*/

/* END BENCHMARK QUERIES */
