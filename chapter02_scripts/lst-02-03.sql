/* Listing 2-3 */

alter system flush buffer_cache;
alter system flush shared_pool;
set autotrace on statistics
select * from hr.employees where department_id = 60;
/*
Statistics
-----------------------------------------------------------
               2  CCursor + sql area evicted
               2  CPU used by this session
               5  CPU used when call started
               5  DB time
              39  Requests to/from client
              38  SQL*Net roundtrips to/from client
             554  buffer is not pinned count
              10  buffer is pinned count
             578  bytes received via SQL*Net from client
           70817  bytes sent via SQL*Net to client
             167  calls to get snapshot scn: kcmgss
              12  calls to kcmgcs
          360448  cell physical IO interconnect bytes
              84  cluster key scan block gets
              61  cluster key scans
             625  consistent gets
             258  consistent gets examination
             248  consistent gets examination (fastpath)
             625  consistent gets from cache
             367  consistent gets pin
             333  consistent gets pin (fastpath)
               1  cursor authentications
               7  enqueue releases
               7  enqueue requests
             156  execute count
              91  file io service time
             105  file io wait time
              44  free buffer requested
              84  index fetch by key
              74  index scans kdiixs1
         5120000  logical read bytes from cache
             355  no work - consistent read gets
              92  non-idle wait count
             156  opened cursors cumulative
               1  opened cursors current
               8  parse count (hard)
               6  parse count (total)
               1  parse time cpu
               1  parse time elapsed
              44  physical read IO requests
          360448  physical read bytes
              44  physical read total IO requests
          360448  physical read total bytes
              44  physical reads
              44  physical reads cache
             370  recursive calls
               1  recursive cpu usage
              16  rows fetched via callback
             154  session cursor cache hits
             625  session logical reads
              32  shared hash latch upgrades - no wait
              48  sorts (memory)
            2424  sorts (rows)
             127  table fetch by rowid
              35  table scan blocks gotten
            1945  table scan disk non-IMC rows gotten
            1945  table scan rows gotten
               5  table scans (short tables)
              39  user calls
*/
set autotrace off

alter system flush buffer_cache;
set autotrace on statistics
select * from hr.employees where department_id = 60;
/*
Statistics
-----------------------------------------------------------
               1  CPU used by this session
               1  CPU used when call started
              39  Requests to/from client
              38  SQL*Net roundtrips to/from client
               3  buffer is not pinned count
               8  buffer is pinned count
             578  bytes received via SQL*Net from client
           74545  bytes sent via SQL*Net to client
               2  calls to get snapshot scn: kcmgss
               2  calls to kcmgcs
           16384  cell physical IO interconnect bytes
               2  consistent gets
               2  consistent gets from cache
               2  consistent gets pin
               2  execute count
               6  file io service time
               5  file io wait time
               2  free buffer requested
               1  index scans kdiixs1
           16384  logical read bytes from cache
               1  no work - consistent read gets
              46  non-idle wait count
               2  opened cursors cumulative
               1  opened cursors current
               2  parse count (total)
               2  physical read IO requests
           16384  physical read bytes
               2  physical read total IO requests
           16384  physical read total bytes
               2  physical reads
               2  physical reads cache
               1  session cursor cache hits
               2  session logical reads
               2  shared hash latch upgrades - no wait
               1  sorts (memory)
            1804  sorts (rows)
               5  table fetch by rowid
              39  user calls
*/

select * from hr.employees where department_id = 60;
set autotrace off

/*

!! No physical reads !!

Statistics
-----------------------------------------------------------
               1  CPU used by this session
               1  CPU used when call started
               1  DB time
              38  Requests to/from client
              38  SQL*Net roundtrips to/from client
               3  buffer is not pinned count
               8  buffer is pinned count
             578  bytes received via SQL*Net from client
           74545  bytes sent via SQL*Net to client
               2  calls to get snapshot scn: kcmgss
               2  calls to kcmgcs
               2  consistent gets
               2  consistent gets from cache
               2  consistent gets pin
               2  consistent gets pin (fastpath)
               2  execute count
               1  index scans kdiixs1
           16384  logical read bytes from cache
               1  no work - consistent read gets
              44  non-idle wait count
               2  opened cursors cumulative
               1  opened cursors current
               2  parse count (total)
              -6  session cursor cache count
               1  session cursor cache hits
               2  session logical reads
               1  sorts (memory)
            1804  sorts (rows)
               5  table fetch by rowid
              39  user calls
              
*/