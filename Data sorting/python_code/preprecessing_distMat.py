import numpy as np
import pandas as pd
from pandas import DataFrame as df
import matplotlib.pyplot as plt
import scipy as sp
import math
from sklearn.manifold import MDS
from scipy.ndimage import gaussian_filter1d

class preprecessing_distMat:

    def __init__(self, Ts, data, save_path):
        self.Ts = Ts
        self.data = data
        self.data_size = np.shape(data)
        self.save_path = save_path

    def peak_delay(self, win):
        """
        Generate PCA data from averaged spike data.
    
        Parameters:
            data: output from pre_processing.datasorting_orientation, "trials X time" in "number of cells X directions" array
            win: timewindow (ms), if sampling rate is 1000hz, win=10 is 10ms
        
        Returns:
            onset_delay(np array): cells X direction
        """
        
        # b=[2,3,9,15,14,13,7,1];
        # label_ori={'Up','Up right', 'Right', 'Down right',...
        #     'Down', 'Down left', 'Left', 'Up left'};
        data_cat = self.data
        
        peak_all = []
        for data_num in range(np.shape(data_cat)[0]):
        
            valcat_t = val_cat[data_num]
            datacat_t = data_cat[data_num]
        
            peak = []
            for a in range(np.shape(data_cat)[1]):
                # Peak
                vv = np.mean(valcat_t[a], axis = 0)
                I = np.where(max(vv) == vv)[0][0]
                s_temp = gaussian_filter1d(np.sum(datacat_t[a], axis = 0), win)
                I2 = np.where(max(s_temp) == s_temp)[0][0]
                peak.append(I2 - I)
            peak_all.append(peak)
        onset_delay = np.array(peak_all) / Ts
    
        return onset_delay

    def peak_MDS(self, onset_delay, fig_on = False):
        """
        Generate PCA data from averaged spike data.
    
        Parameters:
            onset_delay: data from peak_delay
        
        Returns:
            p_t(np array): cells X 2D
        """
    
        p = np.corrcoef(onset_delay)-1
    
        if fig_on:
            plt.imshow(p, aspect='auto', cmap='jet', origin='upper') 
        
        embedding = MDS(dissimilarity='euclidean', random_state = 1)
        p_t = embedding.fit_transform(p)

        return p_t