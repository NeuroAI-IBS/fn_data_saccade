load epoched_data
load ori_templet

type=1; % type=1 is epoched by saccade, 2 is epoched by stimulus

final_cat={};
data_cat={};
val_cat={};
dur_cat={};
rejectedXY_cat={};
for c_num=1:length(total_epodata);

    temp_s=total_epodata{c_num,1};
    X=temp_s{1}; Y=temp_s{2}; TargetXY=[X(:,501),Y(:,501)]; tt=size(X);

    cat_ori=zeros(tt(1),1);
    for a=1:length(ori_templet);

        temp_ot=ori_templet(a,:);
        idx=round(TargetXY)==round(temp_ot);
        %         idx=TargetXY==temp_ot;
        idx2=sum(idx,2);
        idx3=idx2==2;
        cat_ori(idx3)=a;
    end; clear a

    final_cat{c_num,1}=cat_ori;


    % sorting data as orientation
    
    if type==1;
        TT=temp_s{4};
    elseif type==2;
        TT=temp_s{6};
    end
    VV=temp_s{3};
    DD=temp_s{5};

    for a=0:8;
        eval(sprintf("idx%d=cat_ori==%d;",a,a))
    end; clear a

    % spike data sorting
    data_cat{c_num,1}=TT(idx1,:); data_cat{c_num,2}=TT(idx2,:);
    data_cat{c_num,3}=TT(idx3,:); data_cat{c_num,4}=TT(idx4,:);
    data_cat{c_num,5}=TT(idx5,:); data_cat{c_num,6}=TT(idx6,:);
    data_cat{c_num,7}=TT(idx7,:); data_cat{c_num,8}=TT(idx8,:);
    data_cat{c_num,9}=TT(idx0,:);

    % velocity data sorting
    val_cat{c_num,1}=VV(idx1,:); val_cat{c_num,2}=VV(idx2,:);
    val_cat{c_num,3}=VV(idx3,:); val_cat{c_num,4}=VV(idx4,:);
    val_cat{c_num,5}=VV(idx5,:); val_cat{c_num,6}=VV(idx6,:);
    val_cat{c_num,7}=VV(idx7,:); val_cat{c_num,8}=VV(idx8,:);
    val_cat{c_num,9}=VV(idx0,:);

    % duration data sorting
    dur_cat{c_num,1}=DD(idx1,:); dur_cat{c_num,2}=DD(idx2,:);
    dur_cat{c_num,3}=DD(idx3,:); dur_cat{c_num,4}=DD(idx4,:);
    dur_cat{c_num,5}=DD(idx5,:); dur_cat{c_num,6}=DD(idx6,:);
    dur_cat{c_num,7}=DD(idx7,:); dur_cat{c_num,8}=DD(idx8,:);
    dur_cat{c_num,9}=DD(idx0,:);

    % X, Y data for rejected data
    rejectedXY_cat{c_num,1}=X(idx0,:);
    rejectedXY_cat{c_num,2}=Y(idx0,:);


end; clear c_num




% accumulate total cell of each orientation


datacat_total={};
valcat_total={};
datacat_num=[];
for a=1:8;

    temp=[];
    temp2=[];
    temp_num=[];
    for c_num=1:length(data_cat);

        pre_temp=data_cat{c_num,a};
        pre_temp2=val_cat{c_num,a};

        temp=[temp;pre_temp];
        temp2=[temp2;pre_temp2];
        temp_num=[temp_num;size(pre_temp,1)];
    end; clear c_num

    datacat_total{a}=temp;
    valcat_total{a}=temp2;
    datacat_num=[datacat_num temp_num];

end

%% Plotting total

win=20; %timewindow (ms), if sampling rate is 1000hz, win=10 is 10ms
b=[2,3,9,15,14,13,7,1];
label_ori={'Up','Up right', 'Right', 'Down right',...
    'Down', 'Down left', 'Left', 'Up left'};

pos_total=[];
peak=[];
for a=1:8;

    % plotting velocity
    subplot(6,3,b(a))
    vv=mean(valcat_total{a}); [~,I]=max(vv);
    peak(a,1)=I;
    plot(vv,'r')
    xticks([0:50:600])
    xticklabels([-300:50:300])
    ylabel('Eye velocity');

    % Add the text
    xLimits = xlim; % [xmin, xmax]
    yLimits = ylim; % [ymin, ymax]
    xText = xLimits(1) + 0.02 * (xLimits(2) - xLimits(1)); % Slightly right of xmin
    yText = yLimits(2) - 0.15 * (yLimits(2) - yLimits(1)); % Slightly below ymax
    text(xText, yText, label_ori{a}, 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');

    hold on
    plot([300 300],[0 600],'k', 'LineWidth',1);
    hold off

    % plotting heatmap
    subplot(6,3,b(a)+3)
    set(gcf,'color','w')
    imagesc(datacat_total{a});
    colormap(flipud(gray))
    xlabel('Time(ms)');
    ylabel('Trials');

    % Plotting line graph
    s_temp=smoothdata(sum(datacat_total{a}),'gaussian',win);
    [~,I2]=max(s_temp);
    peak(a,2)=I2;
    
    %for octave code
    yyaxis left;
    ax_left = gca;
    plot(s_temp, 'k');
    set(ax_left, 'ycolor', 'k');  % Left y-axis color

    yyaxis right;
    ax_right = gca;
    plot(s_temp, 'r');
    hold on;
    plot([300 300], [0 300], 'k', 'LineWidth', 1);
    ylabel('Spikes');
    set(ax_right, 'ycolor', 'r');  % Right y-axis color

    xticks([0:50:600])
    xticklabels([-300:50:300])
    
    %for matalb code
##    yyaxis right;
##
##    plot(s_temp,'r')
##    hold on
##    plot([300 300],[0 300],'k', 'LineWidth',1);
##    %     ylim([0 300])
##    ylabel('Spikes');
##
##    xticks([0:50:600])
##    xticklabels([-300:50:300])
##   
##    ax = gca;
##    ax.YAxis(1).Color = 'k';
##    ax.YAxis(2).Color = 'r';
    
    ax=gca;
    pos = get(ax, 'Position');
    pos_total=[pos_total;pos];

    hold off

end; clear pos

for a=1:8;

    pos=pos_total(a,:);

    pp=pos(2)+0.01;
    set(subplot(6,3,b(a)), 'Position', [pos(1), pp+0.13, pos(3), pos(4)])
    set(subplot(6,3,b(a)+3), 'Position', [pos(1), pp, pos(3), pos(4)])

end


% bust onset relative to saccade onset(ms)
onset_delay=peak(:,2)-peak(:,1);
subplot(6,3,[8,11])
plot(onset_delay,'k')
ylabel('Bust onset-saccade onset(ms)');
xticks([1:2:8])
xticklabels([0:90:270])
xlabel('Saccade direction({\circ})');
xlim([0 9])

pos=pos_total(3,:);
set(subplot(6,3,[8,11]), 'Position', [pos(1)-0.282, pos(2)+0.036, pos(3), pos(4)*2])

set(gcf,'OuterPosition', [0, 0, 2000, 1000])

tightfig

%% Plotting each

win=20; %timewindow (ms), if sampling rate is 1000hz, win=10 is 10ms
b=[2,3,9,15,14,13,7,1];
label_ori={'Up','Up right', 'Right', 'Down right',...
    'Down', 'Down left', 'Left', 'Up left'};

for data_num=1:size(data_cat,1);

    valcat_t=val_cat(data_num,:);
    datacat_t=data_cat(data_num,:);

    figure

    pos_total=[];
    peak=[];
    for a=1:8;

        % plotting velocity

        subplot(6,3,b(a))
        vv=mean(valcat_t{a}); [~,I]=max(vv);
        peak(a,1)=I;
        plot(vv,'r')
        xticks([0:50:600])
        xticklabels([-300:50:300])
        ylabel('Eye velocity');

        % Add the text
        xLimits = xlim; % [xmin, xmax]
        yLimits = ylim; % [ymin, ymax]
        xText = xLimits(1) + 0.02 * (xLimits(2) - xLimits(1)); % Slightly right of xmin
        yText = yLimits(2) - 0.15 * (yLimits(2) - yLimits(1)); % Slightly below ymax
        text(xText, yText, label_ori{a}, 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');

        hold on
        plot([300 300],[0 600],'k', 'LineWidth',1);
        hold off

        % plotting heatmap
        subplot(6,3,b(a)+3)
        set(gcf,'color','w')
        imagesc(datacat_t{a});
        colormap(flipud(gray))
        xlabel('Time(ms)');
        ylabel('Trials');

        % Plotting line graph
        s_temp=smoothdata(sum(datacat_t{a}),'gaussian',win);
        [~,I2]=max(s_temp);
        peak(a,2)=I2;

        yyaxis right;

        plot(s_temp,'r')
        hold on
        plot([300 300],[0 max(s_temp)],'k', 'LineWidth',1);

        %     ylim([0 300])
        ylabel('Spikes');

        xticks([0:50:600])
        xticklabels([-300:50:300])

        % octave code
        yyaxis left;
        ax_left = gca;
        set(ax_left, 'ycolor', 'k');

        yyaxis right;
        ax_right = gca;
        set(ax_right, 'ycolor', 'r');
        
        % matlab code
##        ax = gca;
##        ax.YAxis(1).Color = 'k';
##        ax.YAxis(2).Color = 'r';
##
##        pos = get(ax, 'Position');
##        pos_total=[pos_total;pos];

        hold off

    end; clear pos

##    for a=1:8;
##
##        pos=pos_total(a,:);
##
##        pp=pos(2)+0.01;
##        set(subplot(6,3,b(a)), 'Position', [pos(1), pp+0.13, pos(3), pos(4)]);
##        set(subplot(6,3,b(a)+3), 'Position', [pos(1), pp, pos(3), pos(4)]);
##
##    end


    % bust onset relative to saccade onset(ms)
    onset_delay=peak(:,2)-peak(:,1);
    subplot(6,3,[8,11])
    plot(onset_delay,'k')
    ylabel('Bust onset-saccade onset(ms)');
    xticks([1:2:8])
    xticklabels([0:90:270])
    xlabel('Saccade direction({\circ})');
    xlim([0 9])
##
##    pos=pos_total(3,:);
##    set(subplot(6,3,[8,11]), 'Position', [pos(1)-0.282, pos(2)+0.036, pos(3), pos(4)*2]);
##
##    set(gcf,'OuterPosition', [0, 0, 2000, 1000])

    tightfig

end

%% Plotting bust onset relative to saccade onset(ms)_average

win=20; %timewindow (ms), if sampling rate is 1000hz, win=10 is 10ms
b=[2,3,9,15,14,13,7,1];
label_ori={'Up','Up right', 'Right', 'Down right',...
    'Down', 'Down left', 'Left', 'Up left'};

peak_all=[];
for data_num=1:size(data_cat,1);

    valcat_t=val_cat(data_num,:);
    datacat_t=data_cat(data_num,:);

    peak=[];
    for a=1:8;

        % Peak
        vv=mean(valcat_t{a}); [~,I]=max(vv);
        peak(a,1)=I;
        s_temp=smoothdata(sum(datacat_t{a}),'gaussian',win);
        [~,I2]=max(s_temp);
        peak(a,2)=I2;
    end

    peak_all=cat(3,peak_all,peak);

end

onset_delay=squeeze(peak_all(:,2,:)-peak_all(:,1,:));

SEM = std(onset_delay')/sqrt(length(onset_delay));
Avg= mean(onset_delay,2);

figure; errorbar(Avg,SEM,'k')

ylabel('Bust onset-saccade onset(ms)');
xticks([1:2:8])
xticklabels([0:90:270])
xlabel('Saccade direction({\circ})');
xlim([0 9])


%% Plotting bust onset relative to saccade onset(ms)_each

win=20; %timewindow (ms), if sampling rate is 1000hz, win=10 is 10ms
b=[2,3,9,15,14,13,7,1];
label_ori={'Up','Up right', 'Right', 'Down right',...
    'Down', 'Down left', 'Left', 'Up left'};

peak_all=[];
for data_num=1:size(data_cat,1);

    valcat_t=val_cat(data_num,:);
    datacat_t=data_cat(data_num,:);

    peak=[];
    for a=1:8;

        % Peak
        vv=mean(valcat_t{a}); [~,I]=max(vv);
        peak(a,1)=I;
        s_temp=smoothdata(sum(datacat_t{a}),'gaussian',win);
        [~,I2]=max(s_temp);
        peak(a,2)=I2;
    end

    peak_all=cat(3,peak_all,peak);

end

onset_delay=squeeze(peak_all(:,2,:)-peak_all(:,1,:));

fig=figure;
for a=1:size(onset_delay,2);

    subplot(8,9,a)
    plot(onset_delay(:,a),'k')
    %     ylabel('Bust onset-saccade onset(ms)');
    title_cell=sprintf("Cell %d",a);
    title(title_cell)
    xticks([1:2:8])
    xticklabels([0:90:270])
    xlabel('Saccade direction({\circ})');
    xlim([0 9])
end

han=axes(fig,'visible','off');
##han.YLabel.Visible='on';
ylabel(han,'Bust onset-saccade onset(ms)');
