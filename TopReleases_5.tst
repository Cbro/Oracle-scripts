PL/SQL Developer Test script 3.0
43
-- Created on 11/04/2008 by MKAUL 
declare 
  -- Local variables here
  i integer;
  vTrackID  track.id%type;
  vRankNum  INTEGER;
  
begin

for x in (
  -- Test statements here
select x.release_id,
       x.rank_num
from         
(
select     /*+ FIRST_ROWS */ y.id release_id,
          row_number() over ( order by y.rel_play_count desc ) rank_num
from    (  
          select r.id,
                 sum(v.play_count) rel_play_count  
          from   service_release sr,
                 v_track_count_forever v,
                 release r,
                 track t
          where  t.id            = v.track_id
          and    sr.service_id   = v.service_id      
          and    r.id            = t.release_id
          and    sr.release_id   = r.id
          and    sr.service_id   = :sid
          and    (sr.release_date is null or sr.release_date < sysdate)
          and    (sr.expiry_date  is null or sr.expiry_date > sysdate)
          group by r.id
         ) y 
) x
where x.rank_num <= :topCount
) loop

dbms_output.put_line('Rel ID    : '|| x.release_id );
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
