% set type
type=1; % 1 is reject minus trial else keep it original

% set epoch period
Ts=1000; % sampling rate
epoch_setting=[-100 300]; % ms


epoch_setting=epoch_setting./1000;
eset=round(epoch_setting*Ts); eset=abs(eset);


% load data list
fileList=dir;
fileList=fileList(7:74);
fileList={fileList.name}';

% epoch
total_epoch={};
for a=1:length(fileList);
    
    load(fileList{a});
    
    s_amp={Saccade.amplitude}';
    s_start={Saccade.start}';
    Time=size(T1); Time=Time(2);
    
    
    % finding epoch time point
    final_epoch={};
    for t_num=1:length(s_amp);
        
        s_ampI=s_amp{t_num};
        temp_amp=zeros(1,length(s_ampI));
        star_idx=s_start{t_num}<500; % before onset
        s_ampI(star_idx)=0;
        
        if max(s_ampI)>7; % amplitude thereshold
            [~,I]=max(s_ampI);
            temp_amp(I)=1;
        end
        
        temp_amp=logical(temp_amp);
        
        if sum(temp_amp)==0;
            c_label=0;
        else
            c_label=1;
        end
        temp_start=s_start{t_num}; temp_start=temp_start(temp_amp);
        
        final_epoch{t_num,1}=t_num; % trial
        final_epoch{t_num,2}=temp_amp; % amplitude > 7 degree
        final_epoch{t_num,3}=temp_start; % start time point
        final_epoch{t_num,4}=c_label; % 1 is exist, 0 is nan
    end; clear t_num temp_amp temp_start
    
    final_epochtime=[];
    for t_num=1:length(final_epoch);
        
        temp_epoch=final_epoch(t_num,:);
        if temp_epoch{4}==0;
            continue
        end
        
        temp_time=temp_epoch{3};
        
        final_ep=[];
        for len_epo=1:length(temp_time);
            
            temp_priod=[temp_time(len_epo)-eset(1), temp_time(len_epo)+eset(2)-1, temp_epoch{1}];
            final_ep=[final_ep;temp_priod];
        end; clear len_epo
        
        final_epochtime=[final_epochtime; final_ep];
        
    end; clear t_num
    
    if type==1;
        final_epochtime2=final_epochtime(final_epochtime(:,1)>0,:);
        final_epochtime2=final_epochtime2(final_epochtime2(:,2)<=Time,:);
    else
        final_epochtime2=final_epochtime;
    end
    
    total_epoch{a,1}=final_epoch; % epoch setting, see details at upper code for final_epoch
    total_epoch{a,2}=final_epochtime2; % epoch period
    total_epoch{a,3}=length(final_epochtime2); % number of total data
    total_epoch{a,4}=length(final_epochtime)-length(final_epochtime2); % number of rejected data
    total_epoch{a,5}=fileList{a};
    
end

save('epoch_setting.mat', 'total_epoch')