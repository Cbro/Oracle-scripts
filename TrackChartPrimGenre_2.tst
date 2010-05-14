PL/SQL Developer Test script 3.0
37
-- Created on 11/04/2008 by MKAUL 
declare 
  -- Local variables here
  i integer;
  vTrackID  track.id%type;
  vRankNum  INTEGER;
  
begin

for x in (
  -- Test statements here
  select  y.track_id,
          y.rank_num
  from (
      select     /*+ FIRST_ROWS */ v.track_id,
                 row_number() over ( order by v.total_count desc ) rank_num
      from       (
                   select   x.service_id,
                            x.track_id,
                            sum(x.customer_play_count) total_count
                   from     track_chart_view x
                   where    x.last_play_date between :chartPeriodStart and :chartPeriodEnd
                   and      x.service_id  = :sid 
                   and      x.primary_genre_id = :prim_gen_id
                   group by x.service_id, 
                            x.track_id
                 ) v
      ) y           
where y.rank_num <= :topCount
) loop

dbms_output.put_line('Track ID  : '|| x.track_id );
dbms_output.put_line('Rank      : '|| x.rank_num );

end loop;

end;
3
prim_gen_id
1
50
3
sid
1
54
3
topCount
1
20
3
0
