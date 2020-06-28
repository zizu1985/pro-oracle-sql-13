alter session set current_schema=sh;
show parameter inmemory
alter system flush shared_pool;
alter session set optimizer_inmemory_aware=FALSE;
alter session set inmemory_query=FALSE;

SELECT p.prod_id, p.prod_name, t.time_id, t.week_ending_day,
 s.channel_id, s.promo_id, s.cust_id, s.amount_sold
 FROM sales s, products p, times t
 WHERE s.time_id=t.time_id AND s.prod_id = p.prod_id;
select * from table(dbms_xplan.display_cursor);

/*
Plan hash value: 187439137
 
----------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name     | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |          |       |       |   542 (100)|          |       |       |
|*  1 |  HASH JOIN                    |          |   918K|    65M|   542   (3)| 00:00:01 |       |       |
|   2 |   PART JOIN FILTER CREATE     | :BF0000  |  1826 | 29216 |    18   (0)| 00:00:01 |       |       |
|   3 |    TABLE ACCESS INMEMORY FULL | TIMES    |  1826 | 29216 |    18   (0)| 00:00:01 |       |       |
|*  4 |   HASH JOIN                   |          |   918K|    51M|   521   (2)| 00:00:01 |       |       |
|   5 |    TABLE ACCESS INMEMORY FULL | PRODUCTS |    72 |  2160 |     3   (0)| 00:00:01 |       |       |
|   6 |    PARTITION RANGE JOIN-FILTER|          |   918K|    25M|   515   (2)| 00:00:01 |:BF0000|:BF0000|
|   7 |     TABLE ACCESS INMEMORY FULL| SALES    |   918K|    25M|   515   (2)| 00:00:01 |:BF0000|:BF0000|
----------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("S"."TIME_ID"="T"."TIME_ID")
   4 - access("S"."PROD_ID"="P"."PROD_ID")
 
Note
-----
   - this is an adaptive plan
*/

CREATE MATERIALIZED VIEW sales_time_product_mv
 ENABLE QUERY REWRITE AS
 SELECT p.prod_id, p.prod_name, t.time_id, t.week_ending_day,
 s.channel_id, s.promo_id, s.cust_id, s.amount_sold
 FROM sales s, products p, times t
 WHERE s.time_id=t.time_id AND s.prod_id = p.prod_id;
 
 
SELECT /*+ rewrite(sales_time_product_mv) */
 p.prod_id, p.prod_name, t.time_id, t.week_ending_day,
 s.channel_id, s.promo_id, s.cust_id, s.amount_sold
 FROM sales s, products p, times t
 WHERE s.time_id=t.time_id AND s.prod_id = p.prod_id;
select * from table(dbms_xplan.display_cursor);
