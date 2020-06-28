alter session set current_schema=hr;

select e1.last_name,e1.salary,v.avg_salary
    from employees e1,
        (SELECT department_id, avg(salary) avg_salary
            FROM employees e2
            GROUP BY department_id) v
    WHERE e1.department_id = v.department_id
        and e1.salary > v.avg_salary
        and e1.department_id = 60;
select * from table(dbms_xplan.display_cursor);

/*

Plan hash value: 3420982931
 
-------------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                        |                   |       |       |     4 (100)|          |
|   1 |  NESTED LOOPS                           |                   |     1 |    31 |     4   (0)| 00:00:01 |
|   2 |   NESTED LOOPS                          |                   |       |       |            |          |
|   3 |    VIEW                                 |                   |     5 |    80 |     2   (0)| 00:00:01 |
|   4 |     HASH GROUP BY                       |                   |     5 |    35 |     2   (0)| 00:00:01 |
|   5 |      TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEES         |     5 |    35 |     2   (0)| 00:00:01 |
|*  6 |       INDEX RANGE SCAN                  | EMP_DEPARTMENT_IX |     5 |       |     1   (0)| 00:00:01 |
|*  7 |    INDEX RANGE SCAN                     | EMP_DEPARTMENT_IX |     5 |       |     1   (0)| 00:00:01 |
|*  8 |   TABLE ACCESS BY INDEX ROWID           | EMPLOYEES         |     1 |    15 |     2   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   6 - access("DEPARTMENT_ID"=60)
   7 - access("E1"."DEPARTMENT_ID"=60)
   8 - filter("E1"."SALARY">"V"."AVG_SALARY")
 
Note
-----
   - this is an adaptive plan
 
 
*/

SELECT e1.last_name, e1.salary, v.avg_salary
 FROM employees e1,
 (SELECT department_id, avg(salary) avg_salary
 FROM employees e2
 WHERE rownum > 1 -- rownum prohibits predicate pushing!
 GROUP BY department_id) v
 WHERE e1.department_id = v.department_id
 AND e1.salary > v.avg_salary
 AND e1.department_id = 60;
select * from table(dbms_xplan.display_cursor);

/*
Plan hash value: 3724319777
 
-----------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |                   |       |       |     6 (100)|          |
|*  1 |  HASH JOIN                            |                   |     3 |   123 |     6  (17)| 00:00:01 |
|   2 |   JOIN FILTER CREATE                  | :BF0000           |     5 |    75 |     2   (0)| 00:00:01 |
|   3 |    TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEES         |     5 |    75 |     2   (0)| 00:00:01 |
|*  4 |     INDEX RANGE SCAN                  | EMP_DEPARTMENT_IX |     5 |       |     1   (0)| 00:00:01 |
|*  5 |   VIEW                                |                   |    11 |   286 |     4  (25)| 00:00:01 |
|   6 |    HASH GROUP BY                      |                   |    11 |    77 |     4  (25)| 00:00:01 |
|   7 |     JOIN FILTER USE                   | :BF0000           |   107 |   749 |     3   (0)| 00:00:01 |
|   8 |      COUNT                            |                   |       |       |            |          |
|*  9 |       FILTER                          |                   |       |       |            |          |
|  10 |        TABLE ACCESS FULL              | EMPLOYEES         |   107 |   749 |     3   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("E1"."DEPARTMENT_ID"="V"."DEPARTMENT_ID")
       filter("E1"."SALARY">"V"."AVG_SALARY")
   4 - access("E1"."DEPARTMENT_ID"=60)
   5 - filter("V"."DEPARTMENT_ID"=60)
   9 - filter(ROWNUM>1)
*/

