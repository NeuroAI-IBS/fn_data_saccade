import os
import numpy as np
import pandas as pd
from pandas import DataFrame as df
import scipy.io as sio


class pre_processing:
    
    def __init__(self, Ts, data_path, save_path):
        self.Ts = Ts
        self.data_path = data_path
        self.save_path = save_path

    def epoch_data(self, p_epoch_setting, save_output = True):
    
        """
        Generate setting for epoch data.
    
        Parameters:
        - epoch_setting: Time of interest(TOI). e.g. [-300, 300] means make epoch data -300ms to 300ms TOI
    
        Returns:
        - total_epoch: Epoch setting for each cell containing:
            - [0]: epoch setting (trial, amplitude > 7 degree, start time point, 1 is exist, 0 is nan, velopcity duration)
            - [1]: epoch period (by Saccade)
            - [2]: number of total data
            - [3]: number of rejected data
            - [4]: file list
            - [5]: epoch period by stimulation (by TargetX and Y)
        """
    
        # Set type
        reject_trials = True  # True is reject minus trial else keep it original
        
        # Set epoch period
        # Ts = 1000  # Sampling rate
        Ts = self.Ts  # Sampling rate, ms
        path = self.data_path
        path2 = self.save_path
        epoch_setting = np.array(p_epoch_setting) / 1000  # in seconds
        eset = np.abs(np.round(epoch_setting * Ts)).astype(int)
        
        # Load data list
        file_list = sorted(os.listdir(path))
        del file_list[5]  # Remove 6th file, because this data seems odd!
    
        # Preprocess data
        total_epoch = []
        
        for fname in file_list:
            data = sio.loadmat(os.path.join(path, fname), squeeze_me=True)
            
            Saccade = data['Saccade']
            T0 = data['T1']
            T1 = T0.toarray()
            TargetX = data['TargetX']
            TargetY = data['TargetY']
            
            s_amp = [s['amplitude'] for s in Saccade]
            s_start = [s['start'] for s in Saccade]
            s_dur = [s['duration'] for s in Saccade]
            Time = T1.shape[1]
        
            # Find epoch time point by stimulus
            sti_epoch = []
            for x, y in zip(TargetX, TargetY):
                temp = np.abs(x) + np.abs(y)
                idx = np.argmax(temp > 1)
                sti_epoch.append(idx)
            
            # Find epoch time point by saccade    
            final_epoch = []
            for t_num in range(len(s_amp)):
                s_ampI = np.array(s_amp[t_num])
                temp_amp = np.zeros(np.size(s_ampI), dtype=bool)
                star_idx=s_start[t_num]<500; # before onset
                s_ampI[star_idx]=0;
        
                if np.max(s_ampI)>7:
                    I = np.argmax(s_ampI)
                    temp_amp[I] = True
        
                if sum(temp_amp)==0:
                    c_label=0;
                else:
                    c_label=1;
        
                if len(temp_amp) < 2:
                    if temp_amp == True:
                        temp_start = s_start[t_num]
                        temp_dur = s_dur[t_num]
                    elif temp_amp == False:
                        temp_start = np.array([])
                        temp_dur = np.array([])
                else:
                    temp_start = s_start[t_num][temp_amp]
                    temp_dur = s_dur[t_num][temp_amp]
        
                final_epoch.append([t_num, temp_amp, temp_start, c_label, temp_dur])
            
            final_epochtime = []
            for t_num in range(len(final_epoch)):
        
                temp_epoch = final_epoch[t_num]
                stif_epoch = sti_epoch[t_num]        
                if temp_epoch[3] == 0:
                    continue
        
                temp_times = temp_epoch[2]
                temp_dur = temp_epoch[4]        
        
                final_ep=[]
                final_ep2=np.array([stif_epoch-eset[0], stif_epoch+eset[1]])
                if np.size(temp_times) < 2:
                    temp_priod=[temp_times-eset[0], temp_times+eset[1], temp_epoch[0], temp_dur]
                    final_ep.append(temp_priod)
                else:
                    for len_epo in range(len(temp_times)):
                        temp_priod=[temp_times[len_epo]-eset[0], temp_times[len_epo]+eset[1], temp_epoch[0], temp_dur]
                        final_ep.append(temp_priod)
        
                final_epochtime.append(np.append(final_ep[0], final_ep2))
        
            final_epochtime=np.array(final_epochtime, dtype=object).astype(int)
            
        
            if reject_trials:
                valid = (final_epochtime[:,0] > 0) & (final_epochtime[:,1] <= Time)
                final_epochtime2 = final_epochtime[valid]
            else:
                final_epochtime2 = final_epochtime
        
            total_epoch.append([
                final_epoch,
                final_epochtime2,
                len(final_epochtime2),
                len(final_epochtime) - len(final_epochtime2),
                fname,
                sti_epoch
            ])
            
        total_epoch=np.array(total_epoch,dtype=object)
    
        return total_epoch
     
        # Save the result
        if save_output == True:
            os.chdir(path2)
            np.save('epoch_setting.npy',total_epoch)

    def run_epoch(self, save_output = True):
    
        """
        Generate epoch data by epoch_setting
    
        Parameters:
        - need epoch_setting.npy
    
        Returns:
        - total_epoch: Epoch setting for each cell containing:
            - [0]: TargetX epoched data
            - [1]: TargetY epoched data
            - [2]: velocity epoched data
            - [3]: T1 epoched data
            - [4]: velopcity duration
            - [5]: T1 epoched data(by stimulus)
        """
        
        path = self.data_path
        path2 = self.save_path
        
        # Load epoch setting
        total_epoch=np.load('epoch_setting.npy', allow_pickle=True)
        
        # Load data list
        os.chdir(path)
        
        # Preprocess data
        total_epodata=[]
        for a in range(len(total_epoch)):
        
            data = sio.loadmat(total_epoch[a,4], squeeze_me=True)
            temp_epoch=total_epoch[a,1]
            T0 = data['T1']
            T2 = T0.toarray()
            TargetX = data['TargetX']
            TargetY = data['TargetY']
            VelV = data['VelV']
        
            # Target stimulation and spike data
            total_data1=[];
            total_data2=[];
            total_data3=[];
            total_data4=[];
            total_data5=[];
            total_data6=[];
            for epo_num in range(np.size(temp_epoch,0)):
                
                tval=temp_epoch[epo_num,:]
                
                # target stimulation
                xx=TargetX[tval[2],:]
                xx2=xx[tval[0]:tval[1]]
                yy=TargetY[tval[2],:]
                yy2=yy[tval[0]:tval[1]]
                
                # velocity data
                VV=VelV[tval[2],:]
                VV2=VV[tval[0]:tval[1]]
                
                # spike data
                TT=T2[tval[2],:]
                TT2=TT[tval[0]:tval[1]]
        
                # spike data epoching by stimulus
                TT3=TT[tval[4]:tval[5]]
                
                total_data1.append(xx2) # TargetX epoched data
                total_data2.append(yy2) # TargetY epoched data
                total_data3.append(VV2) # velocity epoched data
                total_data4.append(TT2) # T1 epoched data
                total_data5.append(tval[3]) # velopcity duration
                total_data6.append(TT3) # T1 epoched data(by stimulus)
                
            total_data1=np.array(total_data1)
            total_data2=np.array(total_data2)
            total_data3=np.array(total_data3)
            total_data4=np.array(total_data4)
            total_data5=np.array(total_data5)
            total_data6=np.array(total_data6)
                
            total_data=[total_data1,total_data2,total_data3, total_data4, total_data5, total_data6]
            total_epodata.append([total_data, total_epoch[a,4]])
        
        total_epodata=np.array(total_epodata,dtype=object)
    
        # Save the result
        os.chdir(path2)
        np.save('epoched_data.npy',total_epodata)


    def datasorting_orientation(self, type):
        """
        Sort data by 8 orientation
    
        Parameters:
        - type: type = 1 is epoched by saccade, 2 is epoched by stimulus
        - need epoched_data.npy
        - need ori_templet.npy
    
        Returns:
        - final_cat
        - data_cat
        - val_cat
        - dur_cat
        - rejectedXY_cat
        """
        
        # Load data
        total_epodata=np.load('epoched_data.npy', allow_pickle=True)
        ori_templet=np.load('ori_templet.npy', allow_pickle=True)
        
        # Preprocess data
        # type=1 # type=1 is epoched by saccade, 2 is epoched by stimulus
    
        final_cat=[]
        data_cat=[]
        val_cat=[]
        dur_cat=[]
        rejectedXY_cat=[]
        for c_num in range(len(total_epodata)):
        
            temp_s=total_epodata[c_num,0]
            X=temp_s[0]; Y=temp_s[1]; TargetXY=[X[:,500],Y[:,500]]; tt=np.shape(X)
            
            cat_ori=np.zeros(tt[0])
            for a in range(len(ori_templet)):
        
                temp_ot=ori_templet[a,:]
                temp_ot=np.tile(temp_ot,np.size(TargetXY,axis=1))
                temp_ot=temp_ot.reshape(np.shape(TargetXY)[1],np.shape(TargetXY)[0])
                idx=np.round(TargetXY)==np.round(temp_ot.T)
                idx2=np.sum(idx, axis=0)
                idx3=idx2==2
                cat_ori[idx3]=a+1
        
            final_cat.append(cat_ori)
        
            # sorting data as orientation
            
            if type==1:
                TT=temp_s[3]
            elif type==2:
                TT=temp_s[5]
        
            VV=temp_s[2]
            DD=temp_s[4]
        
            idx_all = [cat_ori == i for i in range(9)]
        
            # spike data sorting, 1~8: Start from Up direction, clock-wise, [3, 2, 1, 8, 7, 6, 5, 4]: Start from right direction, anticlock-wise
            data_catt=[TT[idx_all[3],:],
                      TT[idx_all[2],:],
                      TT[idx_all[1],:],
                      TT[idx_all[8],:],
                      TT[idx_all[7],:],
                      TT[idx_all[6],:],
                      TT[idx_all[5],:],
                      TT[idx_all[4],:],
                      TT[idx_all[0],:]
                     ]
            data_cat.append(np.array(data_catt, dtype = object))
        
            # velocity data sorting
            val_catt=[VV[idx_all[3],:],
                     VV[idx_all[2],:],
                     VV[idx_all[1],:],
                     VV[idx_all[8],:],
                     VV[idx_all[7],:],
                     VV[idx_all[6],:],
                     VV[idx_all[5],:],
                     VV[idx_all[4],:],
                     VV[idx_all[0],:]
                    ]
            val_cat.append(np.array(val_catt, dtype = object))
        
            # duration data sorting
            dur_catt=[DD[idx_all[3]],
                     DD[idx_all[2]],
                     DD[idx_all[1]],
                     DD[idx_all[8]],
                     DD[idx_all[7]],
                     DD[idx_all[6]],
                     DD[idx_all[5]],
                     DD[idx_all[4]],
                     DD[idx_all[0]]
                    ]
            dur_cat.append(np.array(dur_catt, dtype = object))    
        
            # X, Y data for rejected data
            rejectedXY_catt=np.array([X[idx_all[0],:],Y[idx_all[0],:]])
            rejectedXY_cat.append(rejectedXY_catt)
    
            print(f"Vel_Data_M size_{c_num}:", np.shape(VV)[0], np.shape(DD)[0])
        
        # accumulate total cell of each orientation
        datacat_total=[]
        valcat_total=[]
        datacat_num=[]
        for a in range(8):
        
            temp=[]
            temp2=[]
            temp_num=[]
            for c_num in range(len(data_cat)):
        
                pre_temp=data_cat[c_num][a]
                pre_temp2=val_cat[c_num][a]
        
                temp.append(pre_temp)
                temp2.append(pre_temp2)
                temp_num.append(np.shape(pre_temp)[0])
        
            datacat_total.append(temp)
            valcat_total.append(temp2)
            datacat_num.append(temp_num)
        
        return final_cat, data_cat, val_cat, dur_cat, rejectedXY_cat