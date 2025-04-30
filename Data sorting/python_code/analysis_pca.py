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
        for angle in range(ds-1):
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
            data: direction X cells X time
        
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


    def pca_plot(self, data, onset, type, title = "pca_fig.jpg", save = True):
        """
        Plot for PCA data
    
        Parameters:
            data: dictionary{'v': pca components, 'p': pca transform data, 'dd': explained variance_ratio}
            onset: onset time point (data point)
            title: savefile name
            type: 1~3 for each plot (see details at Returns)
            save: True is save fig
        
        Returns:
            1: Plot variance explained
            2: Plot the principal component weights (the eigenvectors)
            3: Plot the principal component time series (pca transform data)
        """
    
        path = self.save_path
        PCA_total2 = data
        Ts = self.Ts
    
        v = PCA_total2['v']
        p = PCA_total2['p'].T
        dd = PCA_total2['dd']
        
        p_size = np.shape(p)
        
        if type == 1:
            # Plot variance explained
            # Get the explained variance ratio and cumulative sum
            var_explained = np.cumsum(dd) * 100
            
            fig1 = plt.figure()
            plt.plot(var_explained[:20], 'o-', label="Cumulative variance explained")
            plt.xlabel('Dimensions')
            plt.ylabel('Variance explained (%)')
            plt.title('Variance Explained')
        
            if save:
                fig1.savefig(title, dpi=300)
                
            # fig1.show()
        
            return fig1
        
        
        elif type == 2:
            # Plot the principal component weights (the eigenvectors)
            fig2 = plt.figure()
            plt.plot(v.T)  # The components are in rows, so transpose for plotting
            plt.xlabel('Cells')
            plt.ylabel('Weights')
            plt.title('Principal Component Weights')
            plt.tight_layout()
        
            if save:
                fig2.savefig(title, dpi=300)
                
            # fig2.show()
        
            return fig2
        
        
        elif type == 3:
            time1 = onset / Ts * 1000
            time2 = (p_size[1] - onset) / Ts * 1000
            
            # Plot the principal component time series (scores)
            fig3 = plt.figure()
            for i in range(4):  # Plot the first 4 components or up to nmode
                ax = plt.subplot(4, 1, i + 1)
                ax.plot(np.arange(-time1, time2), p[i, :p_size[1]])  # Assuming 600 time steps
                ax.set_title(f'dPC {i + 1}')
                ax.axis('tight')
                ax.get_xaxis().set_ticks([])
            plt.xlabel('Time after saccade onset (ms)')
            plt.tight_layout()
            
            if save:
                fig3.savefig(title, dpi=300)
                
            # fig3.show()
        
            return fig3

    def pca_trajectory_plot(self, data, time_period, type, 
                        rgbC = [0, 0, 0], rgbC_Face = [0.2, 0.2, 0.2], 
                        scatter_size = 10, lineW = 3,
                        win = 1, title = "pca_fig.jpg", save = True):
        """
        Plot for PCA data
    
        Parameters:
            data: dictionary{'v': pca components, 'p': pca transform data, 'dd': explained variance_ratio}
            time_period: time point (data point)
            type: 1~2 for each plot (see details at Returns)
            rgbC: RGB color (0 to 1)
            rgbC_Face: RGB face color (0 to 1)
            scatter_size: scatter_size
            lineW: line width
            win: window size for additional smoothing, if sampling rate is 1000hz, win=10 is 10ms
            title: savefile name
            save: True is save fig
        
        Returns:
            type = 1: Scatter plot for PCA trajectory
            type = 2: Pretty plot for PCA trajectory
        """
    
        from scipy.ndimage import gaussian_filter1d
        
        temp_PC = data['p'].T
        s_temp1 = gaussian_filter1d(temp_PC[0], win)
        s_temp2 = gaussian_filter1d(temp_PC[1], win)
        s_temp3 = gaussian_filter1d(temp_PC[2], win)
    
        X = s_temp1[time_period[0]:time_period[1]]
        Y = s_temp2[time_period[0]:time_period[1]]
        Z = s_temp3[time_period[0]:time_period[1]]
    
        # Plotting
        if type == 1:
            fig1 = plt.figure()
            plt.scatter(X, Y, s = scatter_size, color = rgbC, marker='o')
            
            plt.xlabel('PC1')
            plt.ylabel('PC2')
            # zlabel('PC3')
            
            plt.rc('font', size=15)
            
            if save:
                fig1.savefig(title, dpi=300)
            
            return fig1
        
        elif type == 2:
            
            from matplotlib.markers import CARETUP
            
            fig2 = plt.plot(X, Y, linewidth = lineW, color = rgbC)
            plt.scatter(X[0], Y[0], s=400, color = rgbC, facecolors='none')
            plt.scatter(X[300], Y[300], marker=CARETUP, s=200, color = rgbC, facecolor = rgbC_Face)
            plt.xlabel('dPC1')
            plt.ylabel('dPC2')
        
            if save:
                fig2.savefig(title, dpi=300)
        
            return fig2