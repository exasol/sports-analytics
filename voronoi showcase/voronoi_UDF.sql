
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


	
create or replace PYTHON3 set script voronoi_showcase.voronoi_polygons
	(
	match_id 		varchar(100),
	team_id			varchar(100),
	person_id		varchar(100),
	frame_id		double,
	frame_x			double,
	frame_y			double,
	pitch_size_x	double,
	pitch_size_y	double
	)
emits 
	(
	--test varchar(1000)
	match_id 		  varchar(100),
	team_id		    varchar(100),
	person_id		  varchar(100),
	frame_id		  double,
	voronoi_order	double,
	voronoi_x		double,
	voronoi_y		double
	)
as

import numpy as np
import pandas as pd
import scipy
from scipy.spatial import Voronoi, voronoi_plot_2d
from collections import defaultdict
from shapely.geometry import Polygon

"""function expects point sets for each single frame
of a match. MATCH_ID, TEAM_ID, PERSON_ID and FRAME_ID uniquelly
identify a single frame and each player + ball on the pitch.
So each calculated voronoi polygon can be 
The pitch size is needed to calculated the boundaries for infinite polygons
"""


# function to build voronoi polygons
def voronoi_polygons(voronoi, diameter):
    """Generate shapely.geometry.Polygon objects corresponding to the
    regions of a scipy.spatial.Voronoi object, in the order of the
    input points. The polygons for the infinite regions are large
    enough that all points within a distance 'diameter' of a Voronoi
    vertex are contained in one of the infinite polygons.

    """
    centroid = voronoi.points.mean(axis=0)

    # Mapping from (input point index, Voronoi point index) to list of
    # unit vectors in the directions of the infinite ridges starting
    # at the Voronoi point and neighbouring the input point.
    ridge_direction = defaultdict(list)
    for (p, q), rv in zip(voronoi.ridge_points, voronoi.ridge_vertices):
        u, v = sorted(rv)
        if u == -1:
            # Infinite ridge starting at ridge point with index v,
            # equidistant from input points with indexes p and q.
            t = voronoi.points[q] - voronoi.points[p]  # tangent
            n = np.array([-t[1], t[0]]) / np.linalg.norm(t)  # normal
            midpoint = voronoi.points[[p, q]].mean(axis=0)
            direction = np.sign(np.dot(midpoint - centroid, n)) * n
            ridge_direction[p, v].append(direction)
            ridge_direction[q, v].append(direction)

    for i, r in enumerate(voronoi.point_region):
        region = voronoi.regions[r]
        if -1 not in region:
            # Finite region.
            yield Polygon(voronoi.vertices[region])
            continue
        # Infinite region.
        inf = region.index(-1)  # Index of vertex at infinity.
        j = region[(inf - 1) % len(region)]  # Index of previous vertex.
        k = region[(inf + 1) % len(region)]  # Index of next vertex.
        if j == k:
            # Region has one Voronoi vertex with two ridges.
            dir_j, dir_k = ridge_direction[i, j]
        else:
            # Region has two Voronoi vertices, each with one ridge.
            dir_j, = ridge_direction[i, j]
            dir_k, = ridge_direction[i, k]

        # Length of ridges needed for the extra edge to lie at least
        # 'diameter' away from all Voronoi vertices.
        length = 2 * diameter / np.linalg.norm(dir_j + dir_k)

        # Polygon consists of finite part plus an extra edge.
        finite_part = voronoi.vertices[region[inf + 1:] + region[:inf]]
        extra_edge = [voronoi.vertices[j] + dir_j * length,
                      voronoi.vertices[k] + dir_k * length]
        yield Polygon(np.concatenate((finite_part, extra_edge)))

def run(ctx):	
  #create empty data frame with fixed number of rows
  v_num_rows = ctx.size()
  df_points = pd.DataFrame(index = np.arange(0, v_num_rows), columns= ['match_id', 'team_id', 'person_id', 'frame_id', 'frame_x', 'frame_y'])
  
  #read input parameter into data frame
  for i in np.arange(0, v_num_rows):

    #store point information in data frame
    df_points.loc[i] = [ctx.match_id, ctx.team_id, ctx.person_id, ctx.frame_id, ctx.frame_x, ctx.frame_y]
    
    #store pitch size information
    v_pitch_size_x = ctx.pitch_size_x
    v_pitch_size_y = ctx.pitch_size_y
       
    ctx.next()
	
  #create pitch coordinates based on the size
  pitch = np.array([[(v_pitch_size_x / 2) * -1, (v_pitch_size_y / 2) * -1], [(v_pitch_size_x / 2) * -1, (v_pitch_size_y / 2)], [(v_pitch_size_x / 2), (v_pitch_size_y / 2)], [(v_pitch_size_x / 2), (v_pitch_size_y / 2) * -1], [(v_pitch_size_x / 2) * -1, (v_pitch_size_y / 2) * -1]])

  #get X/Y and build nparray
  points = df_points[['frame_x','frame_y']].values
   
  #create boundary polygone based on pitch coordinates
  boundary_polygon = Polygon(pitch)
  
  diameter = np.linalg.norm(pitch.ptp(axis=0))
 
  i_point = 0
  
  #calculate voronoi polygons for points
  for p in voronoi_polygons(Voronoi(points), diameter):
      
    #build intersect between pitch boundary
    x, y = zip(*p.intersection(boundary_polygon).exterior.coords)

    # get information of associated point
    v_match_id = df_points.loc[i_point, 'match_id'].strip()
    v_team_id = df_points.loc[i_point, 'team_id']
    v_person_id = df_points.loc[i_point, 'person_id']
    v_frame_id = df_points.loc[i_point, 'frame_id']

    i_point = i_point + 1

    #loop points of voronoi polygon
    for i_order in range(0, len(x)):
      #i_order is the corresponding order of the coordinates in
      #the polygon
      v_vor_x = x[i_order]
      v_vor_y = y[i_order]
  
      #emit coordinate of voronoi polygon
      ctx.emit(str(v_match_id), str(v_team_id), str(v_person_id), v_frame_id, i_order, round(v_vor_x,2), round(v_vor_y,2))
	  
/

