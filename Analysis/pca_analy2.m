% For pca to pca

run datasorting_orientation.m
close all
clearvars -except data_cat val_cat


%% preprocessing
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


%% PCA
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
    
    nmode = find(var_explained>80, 1);
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

%% PCA to PCA

close all

pca_data=[];
for a=1:8;
    
    temp=PCA_total{a,2};
    temp=temp(:,1:4);
    pca_data=[pca_data temp];
    
end

[v,p,~,~,dd,~]=pca(pca_data);

figure;
subplot(1,2,1)
plot(dd, 'o-')
xlabel('Dimensions')
ylabel('Explained varience ratio')

subplot(1,2,2)
plot(100*cumsum(dd(1:20))/sum(dd), 'o-');
xlabel('Dimensions')
ylabel('Variance explained (%)')

figure;
%     for i=1:nmode
for i=1:4;
    hx(i) = subplot(4,1,i);
    plot(-300:300-1, p(:,i))
    if i==3;
        set(gca, 'YDir','reverse')
    end
    axis tight
    box off
end

win=1;

figure

s_temp1=smoothdata(p(:,1),'gaussian',win);
s_temp2=smoothdata(p(:,2),'gaussian',win);
s_temp3=smoothdata(p(:,3),'gaussian',win);
X=s_temp1; Y=s_temp2; Z=s_temp3;
scatter3(X,Y,Z,10, "o");

axis square

xlabel('PC1')
ylabel('PC2')
zlabel('PC3')

%%
close all

pca_data=[];
for pc=1:4;
    for a=1:8;
        temp=PCA_total{a,2};
        temp=temp(:,pc);
        pca_data=[pca_data temp];
    end
end


% get betas
betas1 = pca_data(:,1:8) \ p(:,1);
betas2 = pca_data(:,9:16) \ p(:,2);
betas3 = pca_data(:,17:24) \ p(:,3);
betas4 = pca_data(:,25:32) \ p(:,4);

% plot
plot(betas1)
hold on
plot(betas2)
plot(betas3)
plot(betas4)