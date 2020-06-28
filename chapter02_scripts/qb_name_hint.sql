alter session set current_schema=hr;

explain plan for
select /*+ QB_NAME(outer_employees) */ *
from employees where department_id in
(select /*+ QB_NAME(inner_departments) NO_UNNEST index(departments,dept_id_pk) */ department_id from departments);

select * from table(dbms_xplan.display(format=>'ALL +ALIAS'));

/*

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------
 
   1 - SEL$17E8671C / EMPLOYEES@OUTER_EMPLOYEES
 
*/

explain plan for
select /*+ full(@inner_departments departments) */ *
from employees where department_id in
(select /*+ qb_name(inner_departments) */ department_id from departments);

select * from table(dbms_xplan.display(format=>'ALL +ALIAS'));
