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
select x.track_id,
       x.rank_num
from         
(
select     /*+ FIRST_ROWS */ v.track_id track_id,
          row_number() over ( order by v.play_count desc ) rank_num
from      track t,  
          service_track st,
          v_track_count_forever v
where     t.id          = v.track_id 
and       st.service_id = v.service_id
and       st.track_id   = t.id
and       st.service_id = :sid
and      (st.release_date is null or st.release_date < sysdate)
and      (st.expiry_date  is null or st.expiry_date > sysdate)
) x
where x.rank_num <= :topCount

) loop

dbms_output.put_line('Track ID  : '|| x.track_id );
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
