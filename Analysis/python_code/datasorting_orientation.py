import os
import numpy as np
import pandas as pd
from pandas import DataFrame as df

# Load data
total_epodata=np.load('epoched_data.npy', allow_pickle=True)
ori_templet=np.load('ori_templet.npy', allow_pickle=True)


type=1 # type=1 is epoched by saccade, 2 is epoched by stimulus

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

    # spike data sorting
    data_catt=[TT[idx_all[1],:],
              TT[idx_all[2],:],
              TT[idx_all[3],:],
              TT[idx_all[4],:],
              TT[idx_all[5],:],
              TT[idx_all[6],:],
              TT[idx_all[7],:],
              TT[idx_all[8],:],
              TT[idx_all[0],:]
             ]
    data_cat.append(np.array(data_catt))

    # velocity data sorting
    val_catt=[VV[idx_all[1],:],
             VV[idx_all[2],:],
             VV[idx_all[3],:],
             VV[idx_all[4],:],
             VV[idx_all[5],:],
             VV[idx_all[6],:],
             VV[idx_all[7],:],
             VV[idx_all[8],:],
             VV[idx_all[0],:]
            ]
    val_cat.append(np.array(val_catt))

    # duration data sorting
    dur_catt=[DD[idx_all[1]],
             DD[idx_all[2]],
             DD[idx_all[3]],
             DD[idx_all[4]],
             DD[idx_all[6]],
             DD[idx_all[6]],
             DD[idx_all[7]],
             DD[idx_all[8]],
             DD[idx_all[0]]
            ]
    dur_cat.append(np.array(dur_catt))    

    # X, Y data for rejected data
    rejectedXY_catt=np.array([X[idx_all[0],:],Y[idx_all[0],:]])
    rejectedXY_cat.append(rejectedXY_catt)


