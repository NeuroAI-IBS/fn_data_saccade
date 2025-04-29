import os
import numpy as np
import pandas as pd
from pandas import DataFrame as df
import scipy.io as sio
import matplotlib.pyplot as plt


class analysis_pca:
    """
    need filter_matrix.py (Originated by Dr. Sungho Hong)
    Ts: sampling rate
    data: output from pre_processing.datasorting_orientation, "trials X time" in "number of cells X directions" array
    save_path: save path
    """
    
    def __init__(self, Ts, data, save_path):
        self.Ts = Ts
        self.data = data
        self.data_size = np.shape(data)
        self.save_path = save_path

    def smoothing_data(self, sigma = 2):
        """
        Generate spike data with averaged and smoothing by trials.
    
        Parameters:
            sigma: float, optional
                Standard deviation of the Gaussian kernel (default: 2). See details at "filter_matrix.py"
        
        Returns:
            numpy.ndarray (directions X cells X time)
                Filtered and averaged spike data.
        """
    
        ds = self.data_size[1]
        data_cat = self.data
    
        # preprocessing
        data_total = []
        for a in range(ds-1): # orientation
            temp = np.array(data_cat).T[a]
            t_temp = []
            for data_num in range(np.shape(data_cat)[0]):
                temp2 = np.mean(temp[0],axis=0)
                t_temp.append(temp2)
                
            data_total.append(t_temp)
        
        # smothing
        from filter_matrix import filter_matrix
        
        data_cat_sm = []
        for angle in range(8):
            temp_cat = [];
            for n in range(np.shape(data_cat)[0]):
                z = data_cat[n][angle]
                zf = filter_matrix(z,2)
                temp_cat.append(np.mean(zf,axis=0))
                
            data_cat_sm.append(temp_cat)
        
        data_cat_sm = np.array(data_cat_sm)

        return data_cat_sm

    def pca_analy(self, data):
        """
        Generate PCA data from averaged spike data.
    
        Parameters:
            sigma: float, optional
                Standard deviation of the Gaussian kernel (default: 2). See details at "filter_matrix.py"
        
        Returns:
            dictionary[direction]
            {'v': pca components, 'p': pca transform data, 'dd': explained variance_ratio}
        """
    
        data_cat_sm = data
        ds = self.data_size[1] - 1  # number of direction, subtract 1 because last column would be rejected trials
        
        from sklearn.decomposition import PCA
    
        PCA_total = {}
        
        # Loop over the orientations (assuming 8 orientations)
        for ori in range(ds):
            temp_data = data_cat_sm[ori].T  
            pca = PCA()
            pca.fit(temp_data)  # Perform PCA
            v = pca.components_   # coeff
            p = pca.transform(temp_data).T  # scores
            dd = pca.explained_variance_ratio_   # explained variance
        
            # Get the explained variance ratio and cumulative sum
            var_explained = np.cumsum(dd) * 100
            
            # Print the variance explained for the first 5 components
            for i in range(5):
                print(f'Dimensions: {i+1}, Variance explained: {var_explained[i]:.2f}%')
        
            # Find the dimension to reduce to based on cumulative variance explained
            nmode = np.argmax(var_explained > 87.5) + 1
            print(f'Dimensions to be reduced: {nmode}')
            
            # Store PCA results for each orientation
            PCA_total[ori] = {'v': pca.components_, 'p': pca.transform(temp_data), 'dd': pca.explained_variance_ratio_}
    
        return PCA_total

    def pca_to_pca(self, data, dim):
        """
        Generate PCA data from PCA data.
    
        Parameters:
            dictionary[direction]
            {'v': pca components, 'p': pca transform data, 'dd': explained variance_ratio}
        
        Returns:
            dictionary
            {'v': pca components, 'p': pca transform data, 'dd': explained variance_ratio}
        """
    
        PCA_total = data
        ds = self.data_size[1] - 1  # number of direction, subtract 1 because last column would be rejected trials
    
        from sklearn.decomposition import PCA
    
        pca_data = []
        for a in range(ds):
            temp = PCA_total[a]['p']
            temp = temp[:,:dim]
            pca_data.append(temp)
        
        pca_data = np.array(pca_data)
        pca_data = np.concatenate(pca_data, axis = 1)
    
        # PCA_to_PCA analysis
        PCA_total2 = {}
    
        pca = PCA()
        pca.fit(pca_data)  # Perform PCA
        v = pca.components_   # coeff
        p = pca.transform(pca_data).T  # scores
        dd = pca.explained_variance_ratio_   # explained variance
        
        # Get the explained variance ratio and cumulative sum
        var_explained = np.cumsum(dd) * 100
        
        # Print the variance explained for the first 5 components
        for i in range(5):
            print(f'Dimensions: {i+1}, Variance explained: {var_explained[i]:.2f}%')
        
        # Find the dimension to reduce to based on cumulative variance explained
        nmode = np.argmax(var_explained > 95) + 1  # Adding 1 since indexing is 1-based in MATLAB
        print(f'Dimensions to be reduced: {nmode}')
        
        # Store PCA results for each orientation
        PCA_total2 = {'v': pca.components_, 'p': pca.transform(pca_data), 'dd': pca.explained_variance_ratio_}
    
        return PCA_total2