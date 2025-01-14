load epoched_data

final_spike=[];
for a=1:length(total_epodata);
    
    temp=total_epodata{a,1};
    figure; imagesc(temp{3});
    
    final_spike=[final_spike;temp{3}];
    
end    

total_sp_val=[];
for a=1:length(total_epodata);
    
    temp=total_epodata{a,1};
    temp2=temp{3};
    sp_val=log(sum(sum(temp2(:,100:149)))/sum(sum(temp2(:,50:99))));
    total_sp_val=[total_sp_val; sp_val];

end    

figure; plot(sort(total_sp_val))

figure; imagesc(final_spike);
hold on;
plot([100 100],[0 37559],'r', 'LineWidth',1);
xticks([0:50:400])
xticklabels([-100:50:300])


Tx=total_epodata{2,1}{1,1};
Ty=total_epodata{2,1}{1,2};
figure; plot(Tx,Ty)