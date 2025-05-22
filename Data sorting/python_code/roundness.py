import numpy as np
import pandas as pd
from pandas import DataFrame as df
from scipy.spatial import distance
import math

def roundness(data):
    """
    Calculate roundness among the dots (3D)

    Parameters:
    - data (ndarray): dots x axis

    Returns:
    - roundness: ratio between circumference of dots and circle
    """

    def tri_dot_area(x, y, z): 
        dist_xy = distance.euclidean(x, y); dist_xz = distance.euclidean(x, z); dist_yz = distance.euclidean(y, z)
        s = (dist_xy + dist_xz + dist_yz) * 0.5
        area = math.sqrt(s * (s - dist_xy) * (s - dist_xz) * (s - dist_yz))
    
        return area
    
    # Calculation area based on centroid

    centroid = np.mean(data, axis=0)
    temp_d = np.vstack([data, data[0]])
    
    area_t = []
    dist_t = []
    for a in range(np.shape(data)[0]):
    
        area = tri_dot_area(centroid, temp_d[a], temp_d[a+1])
        area_t.append(area)
    
        dist_temp = distance.euclidean(temp_d[a], temp_d[a+1])
        dist_t.append(dist_temp)
    
    sum_area = np.sum(area_t)
    sum_r = np.sum(dist_t)
    
    
    # Calculation roundness
    cir_r = 2 * math.sqrt(np.pi * sum_area)
    output = cir_r / sum_r
    
    return output