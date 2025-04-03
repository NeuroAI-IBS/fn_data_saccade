run datasorting_orientation.m
close all
clearvars -except data_cat val_cat

% preprocessing
data_total={};
for a=1:8; % orientation
    temp=data_cat(:,a);
    t_temp=[];
    for data_num=1:size(data_cat,1);
        temp2=mean(temp{data_num});
        t_temp=[t_temp;temp2];
    end
    data_total{a}=t_temp;
end; clear a;

%% Plotting raw data of each orientation

label_ori={'Up','Up right', 'Right', 'Down right',...
    'Down', 'Down left', 'Left', 'Up left'};
figure
for a=1:8;
    
    subplot(2,4,a)
    imagesc(data_total{a});
    hold on;
    plot([100 100],[0 37559],'r', 'LineWidth',1);
    xticks([0:50:600])
    xticklabels([-300:50:300])
    title(label_ori{a})
    ylabel("Cell#")
    xlabel("Time(ms)")
    colormap("jet")
    
end; clear a

set(gcf,'OuterPosition', [0, 0, 2050, 800])
tightfig

%% smothing

data_cat_sm={};
for angle = 1:8;
    temp_cat=[];
    for n = 1:size(data_cat,1);   

        z = data_cat{n, angle};
        zf = filter_matrix(z', 'sigma', 2)';
        temp_cat=[temp_cat;mean(zf)];
    end
    data_cat_sm{angle}=temp_cat;
end

%% Plotting

label_ori={'Up','Up right', 'Right', 'Down right',...
    'Down', 'Down left', 'Left', 'Up left'};
figure
for a=1:8;
    
    subplot(2,4,a)
    imagesc(data_cat_sm{a});
    hold on;
    plot([300 300],[0 37559],'r', 'LineWidth',1);
    xticks([0:50:600])
    xticklabels([-300:50:300])
    title(label_ori{a})
    ylabel("Cell#")
    xlabel("Time(ms)")
    colormap(jet)
    
end; clear a

set(gcf,'OuterPosition', [0, 0, 2050, 800])
tightfig


%% PCA analysis

PCA_total={};

figure;
num=1;
for ori=1:8; %orientation
    
    temp_data=data_cat_sm{ori};
    [v,p,~,~,dd,~]=pca(temp_data');
    var_explained = cumsum(dd)/sum(dd)*1e2;
    
    for i=1:5
        fprintf('Dimensions: %d, Variance explained: %g', i, var_explained(i));
        fprintf('\n')
    end
    
    nmode = find(var_explained>87.5, 1);
    fprintf('Dimensions to be reduced: %d\n', nmode);
    
    figure;
    plot(100*cumsum(dd(1:20))/sum(dd), 'o-');
    xlabel('Dimensions')
    ylabel('Variance explained (%)')
    
    figure;
    plot(v');
    xlabel('cells')
    ylabel('weights')
    axis tight
    
    figure;
    %     for i=1:nmode
    for i=1:4;
        hx(i) = subplot(4,1,i);
        plot(-300:300-1, p(:,i))
        axis tight
        box off
    end
    linkaxes(hx, 'x')
    xlabel('time after saccade onset (ms)')
    
    PCA_total{ori,1}=v;
    PCA_total{ori,2}=p;
    PCA_total{ori,3}=dd;
    
    num=num+1;
    
end; clear ori

%% Plotting

close all

win=1; %timewindow (ms), if sampling rate is 1000hz, win=10 is 10ms

color=[];
for a=0:7;
    t_color=[1 0+1/9*a 0+1/9*a];
    color=[color;t_color];
end; clear a

figure
for ori=1:8;
    
    temp_PC=PCA_total{ori,2};
    
    s_temp1=smoothdata(temp_PC(:,1),'gaussian',win);
    s_temp2=smoothdata(temp_PC(:,2),'gaussian',win);
    s_temp3=smoothdata(temp_PC(:,3),'gaussian',win);
    
    X=s_temp1(1:600); Y=s_temp2(1:600); Z=s_temp3(1:600);
    scatter3(X,Y,Z,10, color(ori,:), "o");
    hold on
end

axis square

xlabel('PC1')
ylabel('PC2')
zlabel('PC3')

%% Plotting each

close all

win=20; %timewindow (ms), if sampling rate is 1000hz, win=10 is 10ms

color=[];
for a=0:7;
    t_color=[1 0+1/9*a 0+1/9*a];
    color=[color;t_color];
end; clear a

figure

for ori=1:8;
    
    temp_PC=PCA_total{ori,2};
    
    s_temp1=smoothdata(temp_PC(:,1),'gaussian',win);
    s_temp2=smoothdata(temp_PC(:,2),'gaussian',win);
    s_temp3=smoothdata(temp_PC(:,3),'gaussian',win);
    
    subplot(1,8,ori)
    X=s_temp1(1:600); Y=s_temp2(1:600); Z=s_temp3(1:600);
    scatter3(X,Y,Z,10, color(ori,:), "o");
    
    axis square
    
    xlabel('PC1')
    ylabel('PC2')
    zlabel('PC3')
    
end; clear ori

figure
num=1:4:32;
for ori=1:8;
    
    temp_PC=PCA_total{ori,2};
    
    s_temp1=smoothdata(temp_PC(:,1),'gaussian',win);
    s_temp2=smoothdata(temp_PC(:,2),'gaussian',win);
    s_temp3=smoothdata(temp_PC(:,3),'gaussian',win);
    s_temp4=smoothdata(temp_PC(:,4),'gaussian',win);
    
    X=s_temp1(1:600); Y=s_temp2(1:600); Z=s_temp3(1:600); Z2=s_temp4(1:600);
    
    subplot(8,4,num(ori))
    plot(-300:300-1,X)    
    xlabel('Time(ms)')
    ylabel('PC1')
    
    subplot(8,4,num(ori)+1)
    plot(-300:300-1,Y)
    xlabel('Time(ms)')
    ylabel('PC2')

    subplot(8,4,num(ori)+2)
    plot(-300:300-1,Z)
    xlabel('Time(ms)')
    ylabel('PC3')
    set(gca, 'YDir','reverse')

    subplot(8,4,num(ori)+3)
    plot(-300:300-1,Z2)
    xlabel('Time(ms)')
    ylabel('PC4')
    
    %     axis square
    
end; clear ori



%% explained

final=[];

for a=1:8;
    
    temp=PCA_total{a,3};
    final=[final temp];
end


%% dummy

%
% f_c=[];
% for t=1:size(temp_data,2);
%
% [coeff,score,latent,tsquared,explained,mu]=pca(temp_data(:,t));
% f_c=[f_c, coeff];
% end
%
% Xcentered = score*coeff'
% biplot(coeff(:,1:2),'scores',score(:,1:2))
%
% X=coeff(:,1); Y=coeff(:,2); Z=coeff(:,3);
% X=score(1,:); Y=score(2,:); Z=score(3,:);
% scatter(X,Y)
%
%
% %%
%
% data_num=1;
%
% temp_data=data_total{data_num};
%
% for a=1:size(temp_data,2);
%
%     [coeff,score,latent,tsquared,explained,mu]=pca(temp_data(:,:)');
