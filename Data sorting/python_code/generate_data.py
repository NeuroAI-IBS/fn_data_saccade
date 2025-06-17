import random
import numpy as np

def generate_data(data, anything):

    Wa = data[0]
    data_cat_sm = data[1]
    
    irt = np.shape(anything)[0]
    a=0
    final_out = []
    for a in range(irt):

        list_s=np.arange(0,67,1)
        random.shuffle(list_s)
        out_list = list_s[:round(67/3)]
        
        final_outp = []
        for a in range(8):
            out = Wa[:, out_list] @ data_cat_sm[a, out_list, :]
            final_outp.append(out)
    
        final_outp = np.array(final_outp)
        final_out.append(final_outp)
        a = a + 1
    final_out = np.array(final_out)
        
    return final_out