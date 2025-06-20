import random
import numpy as np
import analysis_pca

class generate_data:
    
    def __init__(self, data, Ts):
        self.data = data
        self.Ts = Ts
        self.save_path = '~/user/desktop'
            
    def generate_data1(self, irt):

        data = self.data
        Wa = data[0]
        data_cat_sm = data[1]

        irt = np.shape(irt)[0]
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


    def generate_data2(self, irt):

        data_cat_sm = self.data
        Ts = self.Ts
        save_path = self.save_path
        apca = analysis_pca.analysis_pca(Ts, data_cat_sm, save_path)
        irt = np.shape(irt)[0]

        final_out = []
        for a in range(irt):
            list__ = np.arange(67)
            clist = [random.choice(list__) for i in range(len(list__))]
            clist = np.array(clist)
            
            data_new = data_cat_sm[:, clist, :]
            data = np.mean(data_new, axis=0)  # Anagle averged data
            PCA_total = apca.pca_analy(data)  # PCA
        
            Wa = PCA_total['v'][:4]  # Wight matrix from angle averaged PCA

            final_outp = []
            for a in range(8):
                out_list = data_new[a, :, :]
                out = Wa @ data_new[a, :, :]
                final_outp.append(out)
            final_outp = np.array(final_outp)
            final_out.append(final_outp)
        final_out = np.array(final_out)

        return final_out