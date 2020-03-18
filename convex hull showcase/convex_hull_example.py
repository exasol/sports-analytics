import numpy as np
import pandas as pd
import math
import scipy
from scipy.linalg._interpolative import idd_copycols
from scipy.spatial import ConvexHull, convex_hull_plot_2d
import matplotlib.pyplot as plt
from collections import defaultdict
from shapely.geometry import Polygon



# one example frame
df_points = pd.DataFrame(np.array([
    [-13.02, -19.77],
    [-19.68, -7.46],
    [2.61, -27.24],
    [-19.8, -0.66],
    [-9.61, 0.42],
    [8.96, -0.93],
    [0.11, 8.61],
    [0.27, -5.61],
    [-0.42, -9.35],
    [19.76, 7.11],
    [-6.49, -6.17],
    [-7.31, 10.45],
    [14.36, 24.88],
    [19.4, -9.02],
    [-0.2, 0.2],
    [18.45, -27.28],
    [1.79, 30.07],
    [-16.31, 18.04],
    [-48.51, -0.31],
    [5.93, 6.63],
    [46.06, -0.39],
    [-19.25, 7.96]
    ]), columns=['FRAME_X', 'FRAME_Y'])

v_pitch_size_x = 105
v_pitch_size_y = 68

print(df_points)

#create pitch coordinates based on the size
pitch = np.array([[(v_pitch_size_x / 2) * -1, (v_pitch_size_y / 2) * -1], [(v_pitch_size_x / 2) * -1, (v_pitch_size_y / 2)], [(v_pitch_size_x / 2), (v_pitch_size_y / 2)], [(v_pitch_size_x / 2), (v_pitch_size_y / 2) * -1], [(v_pitch_size_x / 2) * -1, (v_pitch_size_y / 2) * -1]])

print('Pitch coordinates:')
print(pitch)

# get X/Y and build nparray
points = df_points[['FRAME_X', 'FRAME_Y']].values
print('Single points:')
print(points)

#calculate simple voronoi to plot
hull = ConvexHull(points)

# plot points & pitch
x, y = pitch.T
#plt.plot(*points.T, 'b.')

#plot singe points
#plt.show()

#plot voronoi
convex_hull_plot_2d(hull)

print('Hull coordinates')

for vertex in hull.vertices:
    print(points[vertex])

print(hull.vertices)

#Get centoid
c_x = np.mean(hull.points[hull.vertices,0])
c_y = np.mean(hull.points[hull.vertices,1])

print('points:')

i_count = 0

#distance to centoid
for p in points:
    p_x = p[0]
    p_y = p[1]

    p_d = math.sqrt((p_x - c_x)**2 + (p_y - c_y)**2)

    print(p, ' distance: ', p_d)

    v_vertices = hull.vertices

    if i_count in v_vertices:
        v_index = int(np.where(v_vertices == i_count)[0])
        print('in polygon:' + str(i_count) + ' index:' + str(v_index))

    i_count = i_count + 1

#Plot centroid
plt.plot(c_x, c_y,'x',ms=20)
plt.show()

