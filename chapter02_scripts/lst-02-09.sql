/* Listing 2-9 */

-- I want to have stats for all plans 
alter system set "_rowsource_execution_statistics"=TRUE;

SET AUTOTRACE ON EXPLAIN

--explain plan for
SELECT e1.last_name, e1.salary, v.avg_salary
FROM hr.employees e1,
(SELECT department_id, avg(salary) avg_salary
FROM hr.employees e2
GROUP BY department_id) v
WHERE e1.department_id = v.department_id
AND e1.salary > v.avg_salary
AND e1.department_id = 60;

--select * from table(dbms_xplan.display(format => 'ALL ALLSTATS LAST'));
SELECT * FROM   TABLE (DBMS_XPLAN.display_cursor (null, null, 'ALLSTATS LAST'));
-- A-Rows = Starts * E-Rows
/*
--------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name              | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                        |                   |      1 |        |      2 |00:00:00.01 |       4 |       |       |          |
|   1 |  NESTED LOOPS                           |                   |      1 |      1 |      2 |00:00:00.01 |       4 |       |       |          |
|   2 |   NESTED LOOPS                          |                   |      1 |        |      5 |00:00:00.01 |       3 |       |       |          |
|   3 |    VIEW                                 |                   |      1 |      5 |      1 |00:00:00.01 |       2 |       |       |          |
|   4 |     HASH GROUP BY                       |                   |      1 |      5 |      1 |00:00:00.01 |       2 |  1116K|  1116K|  780K (0)|
|   5 |      TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEES         |      1 |      5 |      5 |00:00:00.01 |       2 |       |       |          |
|*  6 |       INDEX RANGE SCAN                  | EMP_DEPARTMENT_IX |      1 |      5 |      5 |00:00:00.01 |       1 |       |       |          |
|*  7 |    INDEX RANGE SCAN                     | EMP_DEPARTMENT_IX |      1 |      5 |      5 |00:00:00.01 |       1 |       |       |          |
|*  8 |   TABLE ACCESS BY INDEX ROWID           | EMPLOYEES         |      5 |      1 |      2 |00:00:00.01 |       1 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------------------
*/

SELECT e1.last_name, e1.salary, v.avg_salary             
FROM hr.employees e1,                                     
(SELECT department_id, avg(salary) avg_salary          
FROM hr.employees e2                                      
WHERE rownum > 1 -- rownum prohibits predicate pushing!
GROUP BY department_id) v                              
WHERE e1.department_id = v.department_id
AND e1.salary > v.avg_salary          
AND e1.department_id = 60;            
