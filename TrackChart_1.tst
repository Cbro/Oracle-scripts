PL/SQL Developer Test script 3.0
44
-- Created on 11/04/2008 by MKAUL 
declare 
  -- Local variables here
  i integer;
  vTrackID  track.id%type;
  vRankNum  INTEGER;
  
begin

for x in (
  -- Test statements here
/*
 select  v.track_id,
         v.rank_num
  from (
          select      x.track_id,
                     row_number() over ( order by x.customer_play_count desc ) rank_num
          from       track_chart_view x
          where      x.last_play_date between sysdate-7 and sysdate 
          and        x.service_id  = :sid 
          ) v           
  where v.rank_num <= :topCount
*/
  
select y.track_id, y.rank_num
from (select /*+ FIRST_ROWS */ v.track_id, row_number() over (order by v.total_count desc) rank_num
from (select x.service_id, x.track_id, sum(x.customer_play_count) total_count
from track_chart_view x
where x.last_play_date between sysdate-7 and sysdate
and x.service_id  = :sid 
group by x.service_id, x.track_id
) v) y
where y.rank_num <= :topCount

  

) loop

dbms_output.put_line('Track ID  : '|| x.track_id );
dbms_output.put_line('Rank      : '|| x.rank_num );

end loop;

end;
2
sid
1
53
3
topCount
1
10
3
0
