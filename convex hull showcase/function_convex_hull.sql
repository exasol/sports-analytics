
/************************************************
	UDF to calculate the voronoi polygons for
	one single frame in a football match.
	
	The function expects group sets for each single frame, so
	the polygons for multiple frames a calculated
	
v1.0:
	- initial


	
parameter:

match_id		unique identifier of a match
team_id			unique identifier of a team
person_id		unique identifier of a person
frame_id		unique identifier of a frame for a single match
frame_x			x coordinated of a player in the single frame
frame_y			y coordinate of a player in the single frame
pitch_size_x	x size of the pitch
pitch_size_y	y size of the pitch

returns:

match_id		unique identifier of a match
team_id			unique identifier of a team
person_id		unique identifier of a person
frame_id		unique identifier of a frame for a single match
voronoi_order	path ordering for the coordinates of a voronoi polygon
voronoi_x		x coordinate of a single point of the voronoi polygon	
voronoi_y		y coordinate of a single point of the voronoi polygon
		
*************************************************/


	
create or replace PYTHON3 set script sandbox.convex_hull_polygons
	(
	match_id 		varchar(100),
	team_id			varchar(100),
	person_id		varchar(100),
	frame_id		double,
	frame_x			double,
	frame_y			double
	)
emits 
	(
	--test varchar(1000)
	match_id 		  varchar(100),
	team_id		    varchar(100),
	person_id		  varchar(100),
	frame_id		  double,
	convex_hull_order	double,
	convex_hull_x		double,
	convex_hull_y		double
	)
as

import numpy as np
import pandas as pd
import scipy
from scipy.spatial import ConvexHull

def run(ctx):	
  #create empty data frame with fixed number of rows
  v_num_rows = ctx.size()
  df_points = pd.DataFrame(index = np.arange(0, v_num_rows), columns= ['match_id', 'team_id', 'person_id', 'frame_id', 'frame_x', 'frame_y'])
  
  #read input parameter into data frame
  for i in np.arange(0, v_num_rows):
  
    #store point information in data frame
    df_points.loc[i] = [ctx.match_id, ctx.team_id, ctx.person_id, ctx.frame_id, ctx.frame_x, ctx.frame_y]
    
    ctx.next()
  
  #get X/Y and build nparray
  points = df_points[['frame_x','frame_y']].values
  
  #Get centoid
	c_x = np.mean(hull.points[hull.vertices,0])
	c_y = np.mean(hull.points[hull.vertices,1])
  
  i_order = 0
  
  #calculate covex hull polygon for points
  for p in ConvexHull(points).vertices:
    
    #store first point
    if (i_order == 0):
      v_p_first = p
  
    # get information of associated point
    v_match_id = df_points.loc[p, 'match_id'].strip()
    v_team_id = df_points.loc[p, 'team_id']
    v_person_id = df_points.loc[p, 'person_id']
    v_frame_id = df_points.loc[p, 'frame_id']
    v_hull_x = df_points.loc[p, 'frame_x']
    v_hull_y = df_points.loc[p, 'frame_y']
  
    #emit coordinate of voronoi polygon
    ctx.emit(str(v_match_id), str(v_team_id), str(v_person_id), v_frame_id, i_order, round(v_hull_x,2), round(v_hull_y,2))
  
    i_order = i_order + 1

  #add first point a second time
  v_match_id = df_points.loc[v_p_first, 'match_id'].strip()
  v_team_id = df_points.loc[v_p_first, 'team_id']
  v_person_id = df_points.loc[v_p_first, 'person_id']
  v_frame_id = df_points.loc[v_p_first, 'frame_id']
  v_hull_x = df_points.loc[v_p_first, 'frame_x']
  v_hull_y = df_points.loc[v_p_first, 'frame_y']

  #emit coordinate of voronoi polygon
  ctx.emit(str(v_match_id), str(v_team_id), str(v_person_id), v_frame_id, i_order, round(v_hull_x,2), round(v_hull_y,2))

/

