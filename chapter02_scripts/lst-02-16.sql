set arraysize 15
alter session set current_schema=oe;
SET AUTOTRACE ON STATISTICS

select * from order_items ;
--   48  consistent gets

set arraysize 45
select * from order_items ;
--    21  consistent gets



