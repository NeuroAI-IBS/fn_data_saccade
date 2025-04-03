run datasorting_orientation.m
close all
clearvars -except data_cat val_cat dur_cat

peak={};
for a=1:size(val_cat,1);
    for ori=1:8;
        temp=val_cat{a,ori};
        peak{a,ori}=max(temp,[],2);
    end
end; clear a ori

final={};
for ori_num = 1:8;
    for a = 1:size(data_cat,1);
        temp_data = data_cat{a, ori_num};
        pram = [peak{a, ori_num},dur_cat{a, ori_num}];
        pram2= mean(pram);
        
        linmod = generate_linear_model(temp_data, pram, pram2);
        final{a,ori_num}=linmod;
    end
end; clear a ori_num


%% plotting

plot_data={};
for ori_num=1:8;

    pp1=[];
    pp2=[];
    pp3=[];
    pp4=[];
    pp5=[];
    for a=1:size(final,1);
        temp=final{a, ori_num};
        temp1=temp.wv0;
        temp2=temp.wv;
        temp3=temp.wr;
        temp4=temp.ssc;
        temp5=temp.ssc0;

        pp1=[pp1;temp1;];
        pp2=[pp2;temp2;];
        pp3=[pp3;temp3;];
        pp4=[pp4;temp4;];
        pp5=[pp5;temp5;];
    end
    
    %smoothing
    zpp1=filter_matrix(pp1', 'sigma', 2)';
    zpp2=filter_matrix(pp2', 'sigma', 2)';
    zpp3=filter_matrix(pp3', 'sigma', 2)';
    zpp4=filter_matrix(pp4', 'sigma', 2)';
    zpp5=filter_matrix(pp5', 'sigma', 2)';

    plot_data{ori_num,1}=zpp1;
    plot_data{ori_num,2}=zpp2;
    plot_data{ori_num,3}=zpp3;
    plot_data{ori_num,4}=zpp4;
    plot_data{ori_num,5}=zpp5;
end


%% plotting

for b=1:5;
    figure;
    for a=1:8;
        subplot(1,8,a)
        imagesc(plot_data{a,b})
    end

    set(gcf,'OuterPosition', [3, 270, 2200, 200])
    tightfig
end


%%
figure
for ori_num=1:8;

    subplot(2,4,ori_num)

    set(gcf,'color','w')
    set(gca,'linewidth',2);

    mtemp=mean(plot_data{ori_num});
    semtemp = std(plot_data{ori_num})/sqrt(length(plot_data{ori_num}));
    time= -300:300-1;
    h= boundedline(time, mtemp, semtemp, 'alpha', 'cmap', [0 0.7 0], 'transparency', 0.3)

    h.LineWidth = 1;
    xlim([-300 300]); ylim([0.02 0.18]);
end

set(gcf,'OuterPosition', [3, 270, 2000, 800])
tightfig

% 
% % GLM regression
% Predictors(:,1)=(squareform(visMat))';
% Predictors(:,2)=(squareform(magMat))';
% 
% % normalize matrices
% Predictors_zscore(:,1)=cosmo_normalize(Predictors(:,1),'zscore');
% Predictors_zscore(:,2)=cosmo_normalize(Predictors(:,2),'zscore');
% Predictors_intercept=[ones(size(Predictors_zscore,1),1) Predictors_zscore];
% 
% % get betas
% betas = Predictors_zscore \ DM_timepoint_zscore;
% betas_intercept = Predictors_intercept \ DM_timepoint_zscore;
% 
% Betas_Vis(s,t)=betas_intercept(2); %first element is a constant, starting from 2 are predictor betas
% Betas_Mag(s,t)=betas_intercept(3);