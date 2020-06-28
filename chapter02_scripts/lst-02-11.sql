/* 
    Listing 2-10 

    Join elimination - outer join case

*/

alter session set current_schema=hr;

alter session set TRACEFILE_IDENTIFIER='JOIN_ELIMINATION_2_11';
ALTER SESSION SET EVENTS='10053 trace name context forever, level 1';

-- Left outer join
select e.first_name, e.last_name, e.job_id
    from employees e left outer join jobs j
    on (e.job_id = j.job_id);
    
ALTER SESSION SET EVENTS '10053 trace name context off';
    
select e.first_name, e.last_name, e.job_id
    from employees e left outer join jobs j
    on (e.job_id = j.job_id);
select * from table(dbms_xplan.display_cursor);

/*

SQL_ID  8cxfmyqmztjgk, child number 0
-------------------------------------
select e.first_name, e.last_name, e.job_id     from employees e left 
outer join jobs j     on (e.job_id = j.job_id)
 
Plan hash value: 2196512024
 
-------------------------------------------------------------------------------------------
| Id  | Operation              | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |                  |       |       |     2 (100)|          |
|   1 |  VIEW                  | index$_join$_001 |   107 |  2568 |     2   (0)| 00:00:01 |
|*  2 |   HASH JOIN            |                  |       |       |            |          |
|   3 |    INDEX FAST FULL SCAN| EMP_NAME_IX      |   107 |  2568 |     1   (0)| 00:00:01 |
|   4 |    INDEX FAST FULL SCAN| EMP_JOB_IX       |   107 |  2568 |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access(ROWID=ROWID)
   
*/

Udalo sie wyeliminowac join elimination 

*************************
Join Elimination [JE:R 12.2]
*************************
SQL:******* UNPARSED QUERY IS *******
SELECT "E"."FIRST_NAME" "FIRST_NAME","E"."LAST_NAME" "LAST_NAME","E"."JOB_ID" "JOB_ID" FROM "HR"."EMPLOYEES" "E","HR"."JOBS" "J" WHERE "E"."JOB_ID"="J"."JOB_ID"(+)
JE:[V2] Query block (0x7f3c60187700) before join elimination:
SQL:******* UNPARSED QUERY IS *******
SELECT "E"."FIRST_NAME" "FIRST_NAME","E"."LAST_NAME" "LAST_NAME","E"."JOB_ID" "JOB_ID" FROM "HR"."EMPLOYEES" "E","HR"."JOBS" "J" WHERE "E"."JOB_ID"="J"."JOB_ID"(+)
JE:[V2]: Try to eliminate J by outer join elim using PRIMARY(JOB_ID)
JE:[V2]: Can eliminate J by outer join elim using PRIMARY(JOB_ID)
JE:[V2] Eliminate table: JOBS (J)
JE:[V2] Query block (0x7f3c60187700) after join elimination:
SQL:******* UNPARSED QUERY IS *******
SELECT "E"."FIRST_NAME" "FIRST_NAME","E"."LAST_NAME" "LAST_NAME","E"."JOB_ID" "JOB_ID" FROM "HR"."EMPLOYEES" "E"
Registered qb: SEL$02426F93 0x60187700 (JOIN REMOVED FROM QUERY BLOCK SEL$2BFA4EE4; SEL$2BFA4EE4; "J"@"SEL$1")
---------------------
QUERY BLOCK SIGNATURE
---------------------
  signature (): qb_name=SEL$02426F93 nbfros=1 flg=0
    fro(0): flg=0 objn=73690 hint_alias="E"@"SEL$1"

query block SEL$948754D7 transformed to SEL$02426F93 (#0)

# Skoro go odrzuci to znaczy ze koszt byl za duzy


    
select /*+ FULL(e) */ e.first_name, e.last_name, e.job_id
    from employees e left outer join jobs j
    on (e.job_id = j.job_id);
select * from table(dbms_xplan.display_cursor);

/*

-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |       |       |     3 (100)|          |
|   1 |  TABLE ACCESS FULL| EMPLOYEES |   107 |  2568 |     3   (0)| 00:00:01 |
-------------------------------------------------------------------------------

*/

----- Optymalizator znalazl lepszy plan dla querasa
--- Full scan on employee -> cost 3.001839
--- Index join -> cost 2.019493

/*
Access path analysis for EMPLOYEES
***************************************
SINGLE TABLE ACCESS PATH
  Single Table Cardinality Estimation for EMPLOYEES[E]
  SPD: Return code in qosdDSDirSetup: NOCTX, estType = TABLE
  Table: EMPLOYEES  Alias: E
    Card: Original: 107.000000  Rounded: 107  Computed: 107.000000  Non Adjusted: 107.000000
  Scan IO  Cost (Disk) =   3.000000
  Scan CPU Cost (Disk) =   64497.200000
  Total Scan IO  Cost  =   3.000000 (scan (Disk))
                       =   3.000000
  Total Scan CPU  Cost =   64497.200000 (scan (Disk))
                       =   64497.200000
  Access Path: TableScan
    Cost:  3.001839  Resp: 3.001839  Degree: 0
      Cost_io: 3.000000  Cost_cpu: 64497
      Resp_io: 3.000000  Resp_cpu: 64497
*/

/*
Index join: Joining index EMP_NAME_IX
Index join: Joining index EMP_JOB_IX
Ix HA Join
  Outer table:  EMPLOYEES  Alias: E
    resc: 1.000813  card 107.000000  bytes:   deg: 1  resp: 1.000813
  Inner table:  <unnamed>  Alias:
    resc: 1.000813  card: 107.000000  bytes:   deg: 1  resp: 1.000813
    using dmeth: 2  #groups: 1
    Cost per ptn: 0.017867  #ptns: 1
    hash_area: 131 (max=25600) buildfrag: 1  probefrag: 1  ppasses: 1
  Hash join: Resc: 2.019493  Resp: 2.019493  [multiMatchCost=0.000000]
  
******** Index join cost ********

Cost: 2.019493

******** Index join OK ********

******** End index join costing ********
  Best:: AccessPath: IndexJoin
         Cost: 2.019493  Degree: 1  Resp: 2.019493  Card: 107.000000  Bytes: 0.000000

*/

-- Jezeli usune job_id, to wtedy powinien zrobic full scan.
-- Ok. Zrobil FULL SCANa bo nie moze dostac email z indexu.
select  e.first_name, e.last_name, e.job_id , e.email
    from employees e left outer join jobs j
    on (e.job_id = j.job_id);
select * from table(dbms_xplan.display_cursor);

/*

SQL_ID  fkrgs58dqh70u, child number 0
-------------------------------------
select  e.first_name, e.last_name, e.job_id , e.email     from 
employees e left outer join jobs j     on (e.job_id = j.job_id)
 
Plan hash value: 1445457117
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |       |       |     3 (100)|          |
|   1 |  TABLE ACCESS FULL| EMPLOYEES |   107 |  3424 |     3   (0)| 00:00:01 |
-------------------------------------------------------------------------------

*/

-- Zrobmy wersje gdzie chcemy gdzies z departments => Nie powinno byc join elimination 
-- Nie moze zrobic. Potwierdzenie w 10053.

alter session set TRACEFILE_IDENTIFIER='JOIN_ELIMINATION_2_11_b';
ALTER SESSION SET EVENTS='10053 trace name context forever, level 1';

-- Left outer join
select e.first_name, e.last_name, e.job_id, j.job_title
    from employees e left outer join jobs j
    on (e.job_id = j.job_id);
    
ALTER SESSION SET EVENTS '10053 trace name context off';

/*
    JE:[V2]: Try to eliminate J by outer join elim using PRIMARY(JOB_ID)
    JE:[V2]: Cannot eliminate J by outer join elim - predicate column refs.
*/

