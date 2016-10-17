savepoint create_order;

insert into orders
 (order_id, order_date, order_mode, order_status, customer_id, sales_rep_id)

--- Add first ordered item and reduce inventory 

savepoint detail_item1 ; 

insert into order_items

update inventories
   set quantity_on_hand = quantity_on_hand - 5
 where product_id = 2255
   and warehouse_id = 1 ;

--- Add second ordered item and reduce inventory 

savepoint detail_item2; 

 (order_id, line_item_id, product_id, unit_price, discount_price, quantity)

update inventories
   set quantity_on_hand = quantity_on_hand - 5
 where product_id = 2274
   and warehouse_id = 1 ;

--- Add third ordered item and reduce inventory

savepoint detail_item3;

insert into order_items
 (order_id, line_item_id, product_id, unit_price, discount_price, quantity)

update inventories
   set quantity_on_hand = quantity_on_hand - 19
 where product_id = 2537
   and warehouse_id = 1 ;

--- Request credit authorization 

savepoint credit_auth; 

exec billing.credit_request(141,7208) ; 

savepoint order_total; 

--- Update order total 

savepoint order_total;

update orders
   set order_total = 7208
 where order_id = 2459; 

select order_id,
       customer,
       mobile,
       status,
       order_total,
       order_date
  from order_detail_header

select line_item_id, 
       product_name, 
       unit_price, 
       discount_price, 
       quantity, 
       line_item_total
       order_detail_line_items
 where order_id = 2459
 order by line_item_id ;
