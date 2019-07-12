
--combine match positions and voronoi polygons
create table voronoi_showcase.match_voronoi as
select
  match_id,
  match_section,
  team_id,
  person_id,
  frame_id,
  frame_timestamp,
  frame_x,
  frame_y,
  NULL voronoi_order,
  NULL voronoi_x,
  NULL voronoi_y
from
  voronoi_showcase.match_position
--optional frame filter
--where
  --frame_id mod 3 = 0 
union all
select
  vor.match_id,
  lkup.match_section,
  vor.team_id,
  vor.person_id,
  vor.frame_id,
  lkup.frame_timestamp,
  NULL frame_x,
  NULL frame_y,
  vor.voronoi_order,
  vor.voronoi_x,
  vor.voronoi_y
from
  (
  select  
    voronoi_showcase.voronoi_polygons(match_id, team_id, person_id, frame_id, frame_x, frame_y, 105, 68)
  from
    voronoi_showcase.MATCH_POSITION
  where
    --no voronoi polygons for the ball  
    team_id <> 'BALL'
    --optional frame filter
    --and frame_id mod 3 = 0 
  group by
    match_id, frame_id
   ) vor
   join voronoi_showcase.MATCH_POSITION lkup
    on vor.match_id = lkup.match_id and
      vor.team_id = lkup.team_id and
      vor.person_id = lkup.person_id and
      vor.frame_id = lkup.frame_id
;
