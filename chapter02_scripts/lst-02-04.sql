alter session set current_schema=oe;

alter session set tracefile_identifier='VIEW_MERGE_TZ';
alter session set events '10053 trace name context forever, level 2';


select *
from orders o,
(select sales_rep_id
from orders
) o_view
where o.sales_rep_id = o_view.sales_rep_id(+)
and o.order_total > 100000;

alter session set events '10053 trace name context off';

select sql_id, sql_text from v$sql where sql_text like '%orders%';
-- bunsu5bhmmdz8

-- Get 10053 trace for sqlid bunsu5bhmmdz8
alter session set events 'trace[rdbms.SQL_Optimizer.*][sql:bunsu5bhmmdz8]';

/*
    CVM:   Merging SPJ view SEL$2 (#0) into SEL$1 (#0)
    Registered qb: SEL$F5BB74E1 0xbbd37700 (VIEW MERGE SEL$1; SEL$2; SEL$1)
*/

alter session set tracefile_identifier='NO_VIEW_MERGE_TZ_new';
alter session set events '10053 trace name context forever, level 2';
select *
from orders o,
(select /*+ NO_MERGE */ sales_rep_id
from orders
) o_view
where o.sales_rep_id = o_view.sales_rep_id(+)
and o.order_total > 100000;

alter session set events '10053 trace name context off';

/*
    Nie ma CVM wcale w sekcji Transoformacji.
*/