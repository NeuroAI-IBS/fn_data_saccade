run datasorting_orientation.m
close all
clearvars -except onset_delay

%% distance matrix based analysis

p=corrcoef(onset_delay);

dist_p=p-1;
dist_p=abs(dist_p);

figure;imagesc(dist_p)
axis square
caxis([0 2])
colorbar
colormap('jet')

Y=cmdscale(dist_p);
Y=Y(:,1:3);


sse_total=[];
for k=1:10;
    [~,~,sumd]=kmeans(Y,k);
    sse=mean(sumd);
    sse_total=[sse_total sse];
end

figure
subplot(1,2,1)
plot(sse_total)
axis square
xlabel("K value")
ylabel("Sum of Distance")

idx=kmeans(Y,4);

color=[1 0 0;...
    0 1 0;...
    0 0 1;...
    0.2 0.2 0.2;...
    0.7 0.7 0.7];

subplot(1,2,2)
for a=1:4;
    
    idx_l=idx==a;
    
    scatter3(Y(idx_l,1),Y(idx_l,2),Y(idx_l,3),500,".","MarkerEdgeColor", color(a,:))
    hold on
end
axis square

xlabel("MD1")
ylabel("MD2")
zlabel("MD3")


%% Characterize patterns in each clusters

for a=1:4;
    subplot(2,2,a)
    idx_l=idx==a;
    
    temp=onset_delay(:,idx_l);
    m_temp=mean(temp,2);
    SEM = std(temp')/sqrt(length(temp));
    errorbar(m_temp,SEM,'k')
    tt=sprintf("Cluster %d",a);
    
    title(tt);
    ylabel('Bust onset-saccade onset(ms)');
    xticks([1:2:8])
    xticklabels([0:90:270])
    xlabel('Saccade direction({\circ})');
    xlim([0 9])
end