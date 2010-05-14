PL/SQL Developer Test script 3.0
36
-- Created on 11/04/2008 by MKAUL 
declare 
  -- Local variables here
  i integer;
  vTrackID  track.id%type;
  vRankNum  INTEGER;
  
begin

for x in (
-- Test statements here
select x.artist_id,
       x.rank_num
from         
(
select     /*+ FIRST_ROWS */ v.artist_id artist_id,
          row_number() over ( order by v.play_count desc ) rank_num
from      artist a,  
          service_artist sa,
          v_artist_count_forever v
where     a.id          = v.artist_id 
and       sa.service_id = v.service_id
and       sa.artist_id   = a.id
and       sa.service_id = :sid
and       a.primary_genre_id = :prim_gen_id
and      (a.first_release_date is null or a.first_release_date < sysdate)
) x
where x.rank_num <= :topCount
) loop

dbms_output.put_line('Artist ID  : '|| x.artist_id );
dbms_output.put_line('Rank      : '|| x.rank_num );

end loop;

end;
3
sid
1
50
3
prim_gen_id
1
50
3
topCount
1
20
3
0
