PL/SQL Developer Test script 3.0
36
-- Created on 11/04/2008 by MKAUL 
declare 
  -- Local variables here
  i integer;
  
begin

for x in (
-- Test statements here
select x.customer_id,
       x.rank_num
from         
(
select     /*+ FIRST_ROWS */ v.customer_id customer_id,
          row_number() over ( order by v.play_count_myplaylist_other desc ) rank_num
from      customer c,  
          customer_preference cp,
          v_customer_count_forever v
where     c.id                     = v.customer_id 
and       c.service_id             = v.service_id
and       cp.customer_id           = c.id
and       c.service_id             = :sid
and       c.pay_by_subscription    = 1
and       cp.show_profile          = 1
and       c.system_user_id         is null
) x
where x.rank_num <= :topCount

) loop

dbms_output.put_line('Customer ID  : '|| x.customer_id );
dbms_output.put_line('Rank      : '|| x.rank_num );

end loop;

end;
2
sid
1
50
3
topCount
1
20
3
0
