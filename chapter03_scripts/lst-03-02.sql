/* 
    Listing 3-2 
    2 razy index.

    Jak wyliczyæ koszty:
        https://clouddba.co/oracle-optimizer-cost-calculations-basic-overview
        How is Parameter DB_FILE_MULTIBLOCK_READ_COUNT Calculated? (Doc ID 1398860.1)
        
    _db_file_optimizer_read_count = 8
    db_file_multiblock_read_count = 128
    _optimizer_cost_model = CHOOSE 
*/

explain plan for
select count(*) ct from t1 where id = 1 ;

select * from table(dbms_xplan.display);

/*
Plan hash value: 3695297570
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |     1 |     3 |     1   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE   |         |     1 |     3 |            |          |
|*  2 |   INDEX RANGE SCAN| T1_IDX1 |   100 |   300 |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
   2 - access("ID"=1) 
*/

alter session set TRACEFILE_IDENTIFIER='ACCESS_METHOD_FULL_3_02a';
ALTER SESSION SET EVENTS='10053 trace name context forever, level 1';
select count(*) ct from t1 where id = 1 ;
ALTER SESSION SET EVENTS '10053 trace name context off';

/*

***************************************
BASE STATISTICAL INFORMATION
***********************
Table Stats::
  Table: T1  Alias: T1
  #Rows: 10000  SSZ: 0  LGR: 0  #Blks:  152  AvgRowLen:  104.00  NEB: 0  ChainCnt:  0.00  ScanRate:  0.00  SPC: 0  RFL: 0  RNF: 0  CBK: 0  CHR: 0  KQDFLG: 1
  #IMCUs: 0  IMCRowCnt: 0  IMCJournalRowCnt: 0  #IMCBlocks: 0  IMCQuotient: 0.000000
Index Stats::
  Index: T1_IDX1  Col#: 1
  LVLS: 1  #LB: 20  #DK: 100  LB/K: 1.00  DB/K: 1.00  CLUF: 154.00  NRW: 10000.00 SSZ: 0.00 LGR: 0.00 CBK: 0.00 GQL: 0.00 CHR: 0.00 KQDFLG: 8192 BSZ: 1
  KKEISFLG: 1
try to generate single-table filter predicates from ORs for query block SEL$1 (#0)
finally: "T1"."ID"=1


Access path analysis for T1
***************************************
SINGLE TABLE ACCESS PATH
  Single Table Cardinality Estimation for T1[T1]
  SPD: Return code in qosdDSDirSetup: NOCTX, estType = TABLE

 kkecdn: Single Table Predicate:"T1"."ID"=1
  Column (#1): ID(NUMBER)
    AvgLen: 3 NDV: 100 Nulls: 0 Density: 0.010000 Min: 0.000000 Max: 99.000000
  Estimated selectivity: 0.010000 , col: #1
  Table: T1  Alias: T1
    Card: Original: 10000.000000  Rounded: 100  Computed: 100.000000  Non Adjusted: 100.000000
  Scan IO  Cost (Disk) =   43.000000
  Scan CPU Cost (Disk) =   2582458.880000
  Cost of predicates:
    io = NOCOST, cpu = 50.000000, sel = 0.010000 flag = 2048  ("T1"."ID"=1)
  Total Scan IO  Cost  =   43.000000 (scan (Disk))
                         + 0.000000 (io filter eval) (= 0.000000 (per row) * 10000.000000 (#rows))
                       =   43.000000
  Total Scan CPU  Cost =   2582458.880000 (scan (Disk))
                         + 500000.000000 (cpu filter eval) (= 50.000000 (per row) * 10000.000000 (#rows))
                       =   3082458.880000
  Access Path: TableScan
    Cost:  43.087871  Resp: 43.087871  Degree: 0
      Cost_io: 43.000000  Cost_cpu: 3082459
      Resp_io: 43.000000  Resp_cpu: 3082459
  Access Path: index (index (FFS))
    Index: T1_IDX1
    resc_io: 7.000000  resc_cpu: 1842429
    ix_sel: 0.000000  ix_sel_with_filters: 1.000000
  Access Path: index (FFS)
    Cost:  7.052522  Resp: 7.052522  Degree: 1
      Cost_io: 7.000000  Cost_cpu: 1842429
      Resp_io: 7.000000  Resp_cpu: 1842429
 ****** Costing Index T1_IDX1
  SPD: Return code in qosdDSDirSetup: NOCTX, estType = INDEX_SCAN
  SPD: Return code in qosdDSDirSetup: NOCTX, estType = INDEX_FILTER
  Estimated selectivity: 0.010000 , col: #1
  Access Path: index (AllEqRange)
    Index: T1_IDX1
    resc_io: 1.000000  resc_cpu: 27971
    ix_sel: 0.010000  ix_sel_with_filters: 0.010000
    Cost: 1.000797  Resp: 1.000797  Degree: 1
  Best:: AccessPath: IndexRange
  Index: T1_IDX1
         Cost: 1.000797  Degree: 1  Resp: 1.000797  Card: 100.000000  Bytes: 0.000000
***************************************

-----------------------------
SYSTEM STATISTICS INFORMATION
-----------------------------
Using dictionary system stats.
  Using NOWORKLOAD Stats
  CPUSPEEDNW: 2923 millions instructions/sec (default is 100)
  IOTFRSPEED: 4096 bytes per millisecond (default is 4096)
  IOSEEKTIM:  10 milliseconds (default is 10)
  MBRC:       NO VALUE blocks (default is 8)

FTS cost calculation (no workload statistics)
    sreadtim := ioseektim + db_block_size/iotrfrspeed.

    sreadtim = 10 + 8192/4096 = 12
    Mreadtim:=ioseektim+db_file_multiblock_read_count *db_block_size/iotrftspeed
               10 + 8 * 8192/4096 = 26
    No. of blocks = 152
    
    Iocost = (No. of blocks/db_file_multiblock_read_count) * (mreadtime/sreadtim) + 1= 
           = 152/8 * (26/12) = 42 = 43

Index Fast Full Scan (FFS)
    Formula for Fast Full Index scan :-
    iocost:=(No. of Leaf Blocks/MBRC)*mreadtim/sreadtim + 1
    cpucost:=#cpu cycles/cpuspeed*(sreadtim*1000)

    No. of Leaf Blocks = 20
    MBRC = 8
    Mreadtim = 26
    Sreadtim = 12
    
    iocost = (20/8)*26/12 = 6 (5.4) + 1 = 7   
    cpucost = 

Wniosek a: Ze dwoch full scan accessow tanszy jest Fast Full Scan.

    Index range scan:
    
    Formula (range scan with one predicate in where clause):
        Formula for Index based scan
        Cost := blevel + ceiling(leaf blocks * effective index selectivity)
        
        Blevel= 1
        Leaf_blocks= 20
        Selectivity= 1/100 = 0.01
        Cost:= 1 + ceiling(20*0.01) = 1

Wniosek b: Najtanszy jest dostep do tabeli A (z predykatem id=1) po range scanie.

*/

select num_rows,blocks,owner from dba_tables where table_name='T1';
-- Num_rows Blocks
-- 10000	152

explain plan for
select /*+ FULL(t1) */count(*) ct from t1 where id = 1 ;

select * from table(dbms_xplan.display);
select operation,options,cost,io_cost from plan_table where plan_id = (select max(plan_id) from plan_table);
/*

SELECT STATEMENT		43	43
SORT	AGGREGATE		
TABLE ACCESS	FULL	43	43

*/





--------------------
---- Table t2   ----
--------------------



explain plan for
select count(*) ct from t2 where id = 1 ;

select * from table(dbms_xplan.display);

/*

Plan hash value: 3450262756
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |     1 |     3 |     1   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE   |         |     1 |     3 |            |          |
|*  2 |   INDEX RANGE SCAN| T2_IDX1 |   100 |   300 |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("ID"=1)
   
*/


alter session set TRACEFILE_IDENTIFIER='ACCESS_METHOD_FULL_3_02b';
ALTER SESSION SET EVENTS='10053 trace name context forever, level 1';
select count(*) ct from t2 where id = 1 ;
ALTER SESSION SET EVENTS '10053 trace name context off';

/*

***************************************
BASE STATISTICAL INFORMATION
***********************
Table Stats::
  Table: T2  Alias: T2
  #Rows: 10000  SSZ: 0  LGR: 0  #Blks:  152  AvgRowLen:  104.00  NEB: 0  ChainCnt:  0.00  ScanRate:  0.00  SPC: 0  RFL: 0  RNF: 0  CBK: 0  CHR: 0  KQDFLG: 1
  #IMCUs: 0  IMCRowCnt: 0  IMCJournalRowCnt: 0  #IMCBlocks: 0  IMCQuotient: 0.000000
Index Stats::
  Index: T2_IDX1  Col#: 1
  LVLS: 1  #LB: 20  #DK: 100  LB/K: 1.00  DB/K: 100.00  CLUF: 10000.00  NRW: 10000.00 SSZ: 0.00 LGR: 0.00 CBK: 0.00 GQL: 0.00 CHR: 0.00 KQDFLG: 8192 BSZ: 1
  KKEISFLG: 1

try to generate single-table filter predicates from ORs for query block SEL$1 (#0)
finally: "T2"."ID"=1

-----------------------------
SYSTEM STATISTICS INFORMATION
-----------------------------
Using dictionary system stats.
  Using NOWORKLOAD Stats
  CPUSPEEDNW: 2923 millions instructions/sec (default is 100)
  IOTFRSPEED: 4096 bytes per millisecond (default is 4096)
  IOSEEKTIM:  10 milliseconds (default is 10)
  MBRC:       NO VALUE blocks (default is 8)

Access path analysis for T2
***************************************
SINGLE TABLE ACCESS PATH
  Single Table Cardinality Estimation for T2[T2]
  SPD: Return code in qosdDSDirSetup: NOCTX, estType = TABLE

 kkecdn: Single Table Predicate:"T2"."ID"=1
  Column (#1): ID(NUMBER)
    AvgLen: 3 NDV: 100 Nulls: 0 Density: 0.010000 Min: 0.000000 Max: 99.000000
  Estimated selectivity: 0.010000 , col: #1
  Table: T2  Alias: T2
    Card: Original: 10000.000000  Rounded: 100  Computed: 100.000000  Non Adjusted: 100.000000
  Scan IO  Cost (Disk) =   43.000000
  Scan CPU Cost (Disk) =   2582458.880000
  Cost of predicates:
    io = NOCOST, cpu = 50.000000, sel = 0.010000 flag = 2048  ("T2"."ID"=1)
  Total Scan IO  Cost  =   43.000000 (scan (Disk))
                         + 0.000000 (io filter eval) (= 0.000000 (per row) * 10000.000000 (#rows))
                       =   43.000000
  Total Scan CPU  Cost =   2582458.880000 (scan (Disk))
                         + 500000.000000 (cpu filter eval) (= 50.000000 (per row) * 10000.000000 (#rows))
                       =   3082458.880000
  Access Path: TableScan
    Cost:  43.087871  Resp: 43.087871  Degree: 0
      Cost_io: 43.000000  Cost_cpu: 3082459
      Resp_io: 43.000000  Resp_cpu: 3082459
  Access Path: index (index (FFS))
    Index: T2_IDX1
    resc_io: 7.000000  resc_cpu: 1842429
    ix_sel: 0.000000  ix_sel_with_filters: 1.000000
  Access Path: index (FFS)
    Cost:  7.052522  Resp: 7.052522  Degree: 1
      Cost_io: 7.000000  Cost_cpu: 1842429
      Resp_io: 7.000000  Resp_cpu: 1842429
 ****** Costing Index T2_IDX1
  SPD: Return code in qosdDSDirSetup: NOCTX, estType = INDEX_SCAN
  SPD: Return code in qosdDSDirSetup: NOCTX, estType = INDEX_FILTER
  Estimated selectivity: 0.010000 , col: #1
  Access Path: index (AllEqRange)
    Index: T2_IDX1
    resc_io: 1.000000  resc_cpu: 27971
    ix_sel: 0.010000  ix_sel_with_filters: 0.010000
    Cost: 1.000797  Resp: 1.000797  Degree: 1
  Best:: AccessPath: IndexRange
  Index: T2_IDX1
         Cost: 1.000797  Degree: 1  Resp: 1.000797  Card: 100.000000  Bytes: 0.000000

***************************************





*/


/* 

Jaki feature powoduje ¿e 12c udaje sie wybrac index do dostepu do danych 


_optimizer_enable_density_improvements

*/

alter system flush shared_pool;
alter session set "_optimizer_enable_density_improvements" = false;

explain plan for
select count(*) ct from t2 where id = 1 ;

select * from table(dbms_xplan.display);



select * from GV$SESSION_FIX_CONTROL where optimizer_feature_enable like '12%' and description like '%random%' order by optimizer_feature_enable desc nulls last;
