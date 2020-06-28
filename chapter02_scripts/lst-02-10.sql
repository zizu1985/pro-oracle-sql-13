/* Listing 2-10 */

alter session set current_schema=hr;
set autotrace traceonly explain

alter session set TRACEFILE_IDENTIFIER='JOIN_ELIMINATION_1a';
ALTER SESSION SET EVENTS='10053 trace name context forever, level 1';
select e.* from employees e, departments d where
    e.department_id = d.department_id;
ALTER SESSION SET EVENTS '10053 trace name context off';
    
select * from table(dbms_xplan.display_cursor);

/*
Plan hash value: 1445457117
 
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |       |       |     3 (100)|          |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |   106 |  7314 |     3   (0)| 00:00:01 |
-------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("E"."DEPARTMENT_ID" IS NOT NULL)
*/

-- Co jest w 10053



Join Elimination [JE:R 12.2]
*************************
SQL:******* UNPARSED QUERY IS *******

SELECT "E"."EMPLOYEE_ID" "EMPLOYEE_ID","E"."FIRST_NAME" "FIRST_NAME","E"."LAST_NAME" "LAST_NAME",
    "E"."EMAIL" "EMAIL","E"."PHONE_NUMBER" "PHONE_NUMBER","E"."HIRE_DATE" "HIRE_DATE","E"."JOB_ID" "JOB_ID","E"."SALARY" "SALARY",
    "E"."COMMISSION_PCT" "COMMISSION_PCT","E"."MANAGER_ID" "MANAGER_ID","E"."DEPARTMENT_ID" "DEPARTMENT_ID" 
    FROM "HR"."EMPLOYEES" "E","HR"."DEPARTMENTS" "D" 
        WHERE "E"."DEPARTMENT_ID"="D"."DEPARTMENT_ID"
        
JE:[V2] Query block (0x7f773da37700) before join elimination:

SQL:******* UNPARSED QUERY IS *******

SELECT "E"."EMPLOYEE_ID" "EMPLOYEE_ID","E"."FIRST_NAME" "FIRST_NAME","E"."LAST_NAME" "LAST_NAME","E"."EMAIL" "EMAIL",
    "E"."PHONE_NUMBER" "PHONE_NUMBER","E"."HIRE_DATE" "HIRE_DATE","E"."JOB_ID" "JOB_ID","E"."SALARY" "SALARY",
    "E"."COMMISSION_PCT" "COMMISSION_PCT","E"."MANAGER_ID" "MANAGER_ID","E"."DEPARTMENT_ID" "DEPARTMENT_ID" 
    FROM "HR"."EMPLOYEES" "E","HR"."DEPARTMENTS" "D" 
        WHERE "E"."DEPARTMENT_ID"="D"."DEPARTMENT_ID"

JE:[V2]: Try to eliminate D by ref. join elim using PRIMARY(DEPARTMENT_ID) <- FOREIGN(DEPARTMENT_ID)
JE:[V2]: Can eliminate D by ref. join elim using PRIMARY(DEPARTMENT_ID) <- FOREIGN(DEPARTMENT_ID)
JE:[V2] Eliminate table: DEPARTMENTS (D)
JE:[V2] Query block (0x7f773da37700) after join elimination:

SQL:******* UNPARSED QUERY IS *******
SELECT "E"."EMPLOYEE_ID" "EMPLOYEE_ID","E"."FIRST_NAME" "FIRST_NAME","E"."LAST_NAME" "LAST_NAME",
    "E"."EMAIL" "EMAIL","E"."PHONE_NUMBER" "PHONE_NUMBER","E"."HIRE_DATE" "HIRE_DATE","E"."JOB_ID" "JOB_ID",
    "E"."SALARY" "SALARY","E"."COMMISSION_PCT" "COMMISSION_PCT","E"."MANAGER_ID" "MANAGER_ID",
    "E"."DEPARTMENT_ID" "DEPARTMENT_ID" 
    FROM "HR"."EMPLOYEES" "E" WHERE "E"."DEPARTMENT_ID" IS NOT NULL
    
Registered qb: SEL$F7859CDE 0x3da37700 (JOIN REMOVED FROM QUERY BLOCK SEL$1; SEL$1; "D"@"SEL$1")
*************************



alter session set TRACEFILE_IDENTIFIER='JOIN_ELIMINATION_1b';
ALTER SESSION SET EVENTS='10053 trace name context forever, level 1';
select e.* from employees e, departments d where
    e.department_id = d.department_id;
ALTER SESSION SET EVENTS '10053 trace name context off';

-- Czy rzeczywiscie department_id jest NOT NULL? 
select * from dba_tab_cols where owner='HR' and table_name='EMPLOYEES';
-- Jest



