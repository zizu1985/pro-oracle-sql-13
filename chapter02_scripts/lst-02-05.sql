/* Listing 2-5 */


set autotrace on

SELECT e1.last_name, e1.salary, v.avg_salary
FROM hr.employees e1,
(SELECT department_id, avg(salary) avg_salary
FROM hr.employees e2
GROUP BY department_id) v
WHERE e1.department_id = v.department_id AND e1.salary > v.avg_salary;

SELECT sql_id,child_number,sql_text FROM v$sql WHERE sql_text LIKE '%last_name%';
--f2rk9wrfx37bv

execute DBMS_SQLDIAG.DUMP_TRACE(p_sql_id=>'f2rk9wrfx37bv',  p_child_number=>0, -
p_component=>'Compiler', -
p_file_id=>'No_merge_tz');

SELECT /*+ MERGE(v) */ e1.last_name, e1.salary, v.avg_salary
FROM hr.employees e1,
(SELECT department_id, avg(salary) avg_salary
FROM hr.employees e2
GROUP BY department_id) v
WHERE e1.department_id = v.department_id AND e1.salary > v.avg_salary;

