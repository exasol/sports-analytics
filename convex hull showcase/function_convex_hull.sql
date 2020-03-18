
/************************************************
	UDF to calculate the convex hull polygons for
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

match_id		            unique identifier of a match
team_id			            unique identifier of a team
person_id		            unique identifier of a person
frame_id		            unique identifier of a frame for a single match
convex_hull_order_order	    path ordering for the coordinates of a voronoi polygon
convex_hull_x		x coordinate of a single point of the voronoi polygon
convex_hull_y		y coordinate of a single point of the voronoi polygon
	
	
*************************************************/


	
create or replace PYTHON3 set script convex_hull_showcase.convex_hull_polygons
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
	frame_x			double,
	frame_y			double,
	convex_hull_order	double,
	convex_hull_x		double,
	convex_hull_y		double,
	convex_hull_distance_centroid double
	)
as

import numpy as np
import pandas as pd
import scipy
import math
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
  
  #calculate hull
  hull = ConvexHull(points)

  #Get centoid
  c_x = np.mean(hull.points[hull.vertices,0])
  c_y = np.mean(hull.points[hull.vertices,1])
  
  i_hull_order = 0
  i_count = 0
  
  #calculate covex hull polygon for points
  for p in points:
  
    # get information of associated point
    v_match_id = df_points.loc[i_count, 'match_id'].strip()
    v_team_id = df_points.loc[i_count, 'team_id']
    v_person_id = df_points.loc[i_count, 'person_id']
    v_frame_id = df_points.loc[i_count, 'frame_id']
    v_frame_x = df_points.loc[i_count, 'frame_x']
    v_frame_y = df_points.loc[i_count, 'frame_y']
    
    #check of part of hull polygone
    if i_count in hull.vertices:
      v_hull_x = df_points.loc[i_count, 'frame_x']
      v_hull_y = df_points.loc[i_count, 'frame_y']
      
      #store first point
      if (i_hull_order == 0):
        v_p_first = p
        
      v_hull_order = int(np.where(hull.vertices == i_count)[0])
      
    else:
      v_hull_order = None
      v_hull_x = None
      v_hull_y = None
    
    #distance to centoid
    v_distance = math.sqrt((v_frame_x - c_x)**2 + (v_frame_y - c_y)**2)
  
    #emit coordinate of voronoi polygon
    ctx.emit(str(v_match_id), str(v_team_id), str(v_person_id), v_frame_id, v_frame_x, v_frame_y, v_hull_order, v_hull_x, v_hull_y, v_distance)
  
    i_count = i_count + 1


/
