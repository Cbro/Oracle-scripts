PL/SQL Developer Test script 3.0
32
-- Created on 11/04/2008 by MKAUL 
declare 
  -- Local variables here
  i integer;
  
begin

for x in (
-- Test statements here
select x.playlist_id,
       x.rank_num
from         
(
select     /*+ FIRST_ROWS */ v.playlist_id playlist_id,
          row_number() over ( order by v.play_count desc ) rank_num
from      playlist p,  
          v_playlist_count_forever v
where     p.id                     = v.playlist_id 
and       p.service_id             = v.service_id
and       p.service_id             = :sid
and       p.enabled                = 1
) x
where x.rank_num <= :topCount

) loop

dbms_output.put_line('Playlist ID  : '|| x.playlist_id );
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
