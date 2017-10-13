Join a rate table with an arrray of posibilties on each record to the primary table.
The power of normalization
There are other soltions (ie hash, catesian with condition)
However I like having the normalized table as a by product is often useful.

   WORKING CODE
   SAS/WPS

       * normalize the arrays in the payrate tabe;
         array rats r:;
         array cdes p:;
         do i=1 to dim(rats);
           rat=rats[i];
           cde=cdes[i];
           keep user rat cde;
           output;
         end;

         * joint the two tables;
         select
            l.*
           ,r.rat
         from
           hour as l left join paynrm as r
         on
               l.user = r.user
          and  l.project_code = r.cde

see
https://goo.gl/TXokHb
https://communities.sas.com/t5/Base-SAS-Programming/Merging-table-row-on-colum/m-p/403756


HAVE   (the two tables)
====

RULES
=====
            Primary Table                   Table of Arrays

                  PROJECT_     HOUR_   |  Possible codes and rates for harry
  Obs    USER       CODE      WORKING  |  code/rate  code/rate   code/rate

                                       |
   1     harry       160         3     |  160/300    150/800      ./.   since project_code=160 select 300

   2     harry       150         8     |  160/300    150/800      ./.   since project_code=150 select 800
                                       |

WORK.HOUR total obs=6

                  PROJECT_     HOUR_
  Obs    USER       CODE      WORKING

   1     harry       160         3
   2     harry       150         8
   3     lucy        220         3
   4     john        120         3
   5     john        110         1
   6     john        100         9


WORK.PAYRATE total obs=3

                PROJECT_             PROJECT_             PROJECT_
Obs    USER       CODE1     RATE1      CODE2     RATE2      CODE3     RATE3

 1     harry       160       300        150       800          .        .
 2     lucy        220       300          .         .          .        .
 3     john        120       300        110       100        100        .


WANT
=====

The WPS System

USER   PROJECT_CODE  HOUR_WORKING       RAT
-------------------------------------------
harry           150             8       800
harry           160             3       300
john            100             9         .
john            110             1       100
john            120             3       300
lucy            220             3       300


*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data hour;
input user $ project_code hour_working;
datalines;
harry 160 3
harry 150 8
lucy 220 3
john 120 3
john 110 1
john 100 9
;
run;

data payrate;
input user $ project_code1 rate1 project_code2 rate2 project_code3 rate3;
datalines;
harry 160 300 150 800 . .
lucy 220 300 . . . .
john 120 300 110 100 100 900xzy 1000 300 . . . . . .
;
run;

*                                _       _   _
__      ___ __  ___    ___  ___ | |_   _| |_(_) ___  _ __
\ \ /\ / / '_ \/ __|  / __|/ _ \| | | | | __| |/ _ \| '_ \
 \ V  V /| |_) \__ \  \__ \ (_) | | |_| | |_| | (_) | | | |
  \_/\_/ | .__/|___/  |___/\___/|_|\__,_|\__|_|\___/|_| |_|
         |_|
;


%utl_submit_wps64('
libname wrk "%sysfunc(pathname(work))";
data paynrm;
  set wrk.payrate;
  array rats r:;
  array cdes p:;
  do i=1 to dim(rats);
    rat=rats[i];
    cde=cdes[i];
    keep user rat cde;
    output;
  end;
run;quit;

proc sql;
  select
     l.*
    ,r.rat
  from
    wrk.hour as l left join wrk.paynrm as r
  on
        l.user = r.user
   and  l.project_code = r.cde
;quit;
');

*                           _       _   _
 ___  __ _ ___    ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _` / __|  / __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_| \__ \  \__ \ (_) | | |_| | |_| | (_) | | | |
|___/\__,_|___/  |___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

data paynrm;
  set payrate;
  array rats r:;
  array cdes p:;
  do i=1 to dim(rats);
    rat=rats[i];
    cde=cdes[i];
    keep user rat cde;
    output;
  end;
run;quit;

proc sql;
  create
     table want as
  select
     l.*
    ,r.rat
  from
    hour as l left join paynrm as r
  on
        l.user = r.user
   and  l.project_code = r.cde
;quit;
