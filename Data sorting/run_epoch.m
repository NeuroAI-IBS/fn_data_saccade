load epoch_setting

% reject file
% total_epoch(6,:)=[];

path='C:\Users\user\Desktop\Saccadic\left\data'
cd(path)

total_epodata={};
for a=1:length(total_epoch);
    
    load(total_epoch{a,5})
    temp_epoch=total_epoch{a,2};
    T2=full(T1);    
    
    % Target stimulation and spike data
    total_data1=[];
    total_data2=[];
    total_data3=[];
    total_data4=[];
    total_data5=[];
    total_data6=[];
    for epo_num=1:length(temp_epoch);
        
        tval=temp_epoch(epo_num,:);
        
        % target stimulation
        xx=TargetX(tval(3),:);
        xx2=xx(tval(1):tval(2));
        yy=TargetY(tval(3),:);
        yy2=yy(tval(1):tval(2));
        
        % velocity data
        VV=VelV(tval(3),:);
        VV2=VV(tval(1):tval(2));
        
        % spike data
        TT=T2(tval(3),:);
        TT2=TT(tval(1):tval(2));

        % spike data epoching by stimulus
        TT3=TT(tval(5):tval(6));
        
        total_data1=[total_data1;xx2]; % TargetX epoched data
        total_data2=[total_data2;yy2]; % TargetY epoched data
        total_data3=[total_data3;VV2]; % velocity epoched data
        total_data4=[total_data4;TT2]; % T1 epoched data
        total_data5=[total_data5;tval(4)]; % velopcity duration
        total_data6=[total_data6;TT3]; % T1 epoched data(by stimulus)
        
    end
    
    total_data={total_data1,total_data2,total_data3, total_data4, total_data5, total_data6};
    total_epodata{a,1}=total_data;
    total_epodata{a,2}=total_epoch{a,5};
    
end

cd('C:\Users\user\Desktop\Saccadic\left')
save("epoched_data.mat", "total_epodata")
