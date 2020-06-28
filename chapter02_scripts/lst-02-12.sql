/*

Listing 2-12 
    Order By Elimination = avoid sorts.
    SORT AGGREGATE -> tak naprawdê nie jest sortowaniem.
    
    ORDER_BY_ELIMINATION_2_12a -> Order By elimination used
    
*/

-- Prereqs
alter session set current_schema=hr;

select count(*) from
(
    select d.department_name
    from departments d
    where d.manager_id = 201
    order by d.department_name
);
-- 1

select count(*) from
(
    select d.department_name
    from departments d
    where d.manager_id = 201
    order by d.department_name
);
select * from table(dbms_xplan.display_cursor);

/*
Plan hash value: 1270001327
 
----------------------------------------------------------------------------------
| Id  | Operation          | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |             |       |       |     3 (100)|          |
|   1 |  SORT AGGREGATE    |             |     1 |     3 |            |          |
|*  2 |   TABLE ACCESS FULL| DEPARTMENTS |     1 |     3 |     3   (0)| 00:00:01 |
----------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - filter("D"."MANAGER_ID"=201) 
*/


select /*+ no_query_transformation */ count(*) from
 (
 select d.department_name
 from departments d
 where d.manager_id = 201
 order by d.department_name
 ) ;
select * from table(dbms_xplan.display_cursor);
/*

Plan hash value: 1233823892
 
------------------------------------------------------------------------------------
| Id  | Operation            | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |             |       |       |     4 (100)|          |
|   1 |  SORT AGGREGATE      |             |     1 |       |            |          |
|   2 |   VIEW               |             |     1 |       |     4  (25)| 00:00:01 |
|   3 |    SORT ORDER BY     |             |     1 |    15 |     4  (25)| 00:00:01 |
|*  4 |     TABLE ACCESS FULL| DEPARTMENTS |     1 |    15 |     3   (0)| 00:00:01 |
------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - filter("D"."MANAGER_ID"=201)
 
*/

-- Co jest w 10053
alter session set TRACEFILE_IDENTIFIER='ORDER_BY_ELIMINATION_2_12a';
ALTER SESSION SET EVENTS='10053 trace name context forever, level 1';

select count(*) from
(
    select d.department_name
    from departments d
    where d.manager_id = 201
    order by d.department_name
);

ALTER SESSION SET EVENTS '10053 trace name context off';

-- ORDER BY ELIMINATION. Trace 10053

***************************
Order-by elimination (OBYE)
***************************
OBYE:   Considering Order-by Elimination from view SEL$2 (#0)
***************************
Order-by elimination (OBYE)
***************************
OBYE: Removing order by from query block SEL$2 (#0) (order not used)
Registered qb: SEL$73523A42 0x98523688 (ORDER BY REMOVED FROM QUERY BLOCK SEL$2; SEL$2)

Final query after transformations:******* UNPARSED QUERY IS *******
SELECT COUNT(*) "COUNT(*)" FROM "HR"."DEPARTMENTS" "D" WHERE "D"."MANAGER_ID"=201
kkoqbc: optimizing query block SEL$51F12574 (#0)

        :
    call(in-use=3072, alloc=16344), compile(in-use=83456, alloc=86864), execution(in-use=3576, alloc=4032)

kkoqbc-subheap (create addr=0x7f0b9852fb78)

/*
    _optimizer_order_by_elimination_enabled = true
    Hintów nie ma.
*/

-- Wylaczenie OBYE za pomoca hinta
-- http://www.dba-oracle.com/t_opt_param_hidden_parameters.htm

alter session set current_schema=hr;
alter session set TRACEFILE_IDENTIFIER='ORDER_BY_ELIMINATION_2_12b';
ALTER SESSION SET EVENTS='10053 trace name context forever, level 1';
select /*+ OPT_PARAM('_optimizer_order_by_elimination_enabled' 'false') */ count(*) from
 (
 select d.department_name
 from departments d
 where d.manager_id = 201
 order by d.department_name
 ) ;

ALTER SESSION SET EVENTS '10053 trace name context off';

/*
***************************
Order-by elimination (OBYE)
***************************
OBYE:     OBYE bypassed: Disabled by parameter.
OBYE:     OBYE bypassed: no order by to eliminate.
*/ 

