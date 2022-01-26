 function PFS1_meng08aug18()
clear all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%　　　　　　　　　　　　　记录仿真系统文档                                 %
%比例公平调度
%neraspace, revised on Aug 18,2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fpname = strcat(mfilename, '.txt');
fp = fopen(fpname,'a+');
fprintf(fp,'\n\n*****************************************************************************\n');
fprintf(fp,'+ +Proportional Fair Scheduling,The Simulated Date: %12s  + + + +\n',datestr(now));
fprintf(fp,'+ +             Note: SISO , Rayleigh fading channels      　　　         + + + +\n');
fprintf(fp,'*****************************************************************************\n');
fprintf(fp,'*-------------------------设置系统参数-------------------------------*\n');
Tx = 1;

Rx = 1;

fprintf(fp,'\n');

fprintf(fp,'*-------------------------设置仿真参数-------------------------------*\n');
Simtime = 10000;
fprintf(fp, 'The Simulated time slot Number = %d \n',Simtime);
NumUser=10;  

EsN0dB_Aveage=0;                        
EsN0_Aveage=10^(EsN0dB_Aveage/10);     
Num_group=2;                            
Num_eachgroup=ceil(NumUser/Num_group); 
EsN0dB_unsymmetrical=[-5 +5]*1;
SNRgap=ceil(max(EsN0dB_unsymmetrical)-min(EsN0dB_unsymmetrical));
EsN0_unsymmetrical = 10.^(EsN0dB_unsymmetrical/10);
if SNRgap==0
    fprintf(fp, ' EsN0dB_Aveage=%4d, and symmetrical channel, \n',EsN0dB_Aveage);
else
    fprintf(fp, ' EsN0dB_Aveage=%4d, and unsymmetrical channel, \n',EsN0dB_Aveage);
    for i=1:Num_group
        fprintf(fp, 'EsN0dB_unsymmetrical=%4d \n',EsN0dB_unsymmetrical(i)); 
    end
end

count=zeros(1,NumUser);
j=1;
THPUT=0;

for time = 1:Simtime
    T_alluser(time)=0; 
 
        if mod(time,100000) == 0
            fprintf('time = %d\r',time);
        end    
    H = sqrt(1/2)*(randn(Tx,NumUser) + sqrt(-1)*randn(Tx,NumUser));

    Hi=abs(H).^2;
  
          
    for igroup=1:Num_group  
       Hgain((igroup-1)*Num_eachgroup+1:igroup*Num_eachgroup)=...
          Hi((igroup-1)*Num_eachgroup+1:igroup*Num_eachgroup)*EsN0_unsymmetrical(igroup);
    end


   THPUT=THPUT+log(1+Hgain(j)*EsN0_Aveage);
    

    
    k=j;
    
    j=j+1;
    if mod(j,NumUser)==1
        j=1;
    end
    
    count(k)=count(k)+1;
    
      
    
end
Ta=THPUT/Simtime;
fprintf(fp, 'The average throughput of all users,Ta=%4.1f,bit/s/Hz. \n',Ta); 
figure(1);
SCH_rate=count./Simtime;
bar(SCH_rate,'b');
title(['Round Robin',strcat(',User=',int2str(NumUser),...
     ',EsN0dB-Av=',int2str(EsN0dB_Aveage), 'dB,SNRgap=',int2str(SNRgap)), 'dB,Ta=',int2str(Ta),'bit/s']); 
 hold on;grid on;
 xlabel('The Users Serial Number');ylabel('The Scheduling Time per User')



fclose(fp);


