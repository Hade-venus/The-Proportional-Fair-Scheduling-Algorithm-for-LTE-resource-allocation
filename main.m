clear all
close all
clc
%% parameters
Delay_considering_FLAG = 1; %1:consider delay 0: not consider delay
UE1_Capacity = 100e6; %UE1 of URLLC  capacity bps
UE2_Capacity = 40e6; %UE2 of eMBB capacity bps
B_ss = 15e3; %subcarrier spacing bandwidth Hz
B_total = 10e6; %total bandwidth Hz
se = 6.36; % average spectral efficiency bps/Hz
Ns_perRB = 12; %number of subcarriers per RB
N_RB_persymbol = floor(B_total/(Ns_perRB*B_ss)); % number of RBs per symbol
Nsymbol_perslot = 14; %number of OFDM symbols per slot
t_slot = 1e-3; % 1 slot duration s
t_symbol = t_slot/Nsymbol_perslot; %1 OFDM symbol duration s
UE1_max_delay = 0.5e-3; %max delay for UE1 s
UE2_max_delay = 5e-3; %max delay for UE2 s
if ~Delay_considering_FLAG
    UE1_max_delay = 1000e-3; %max delay for UE1 s
    UE2_max_delay = 1000e-3; %max delay for UE2 s
end

% UE1_RB = floor(UE1_Capacity/(B_ss*se*Ns_perRB)); %number of RBs for UE1
% UE2_RB = floor(UE2_Capacity/(B_ss*se*Ns_perRB)); %number of RBs for UE2
% N_symbol = ceil((UE1_RB+UE2_RB)/N_RB_persymbol); %number of symbols needed

%% PF scheduler
UE1_RB_sd = 0; %number of scheduled RBs for UE1
UE2_RB_sd = 0; %number of scheduled RBs for UE2
alpha = 0.5; %PF scheduling balance parameter

averageDR1 = 0; %data rate for UE1
averageDR2 = 0; %data rate for UE2

for n1 = 1:15
    if (averageDR1 > UE1_Capacity) && (averageDR2 > UE2_Capacity)
        break
    end
    for n2 = 1:N_RB_persymbol
        if averageDR1 < UE1_Capacity
            delay_UE1 = n1*t_symbol; %current delay
            achievableDR = se*Ns_perRB*B_ss; % achievable data rate (bit/s)
            total_R_UE1 = 0.01+se*Ns_perRB*B_ss*UE1_RB_sd*t_symbol; %total transmitted bits
            averageDR1 = total_R_UE1/(n1*t_symbol); % update average past data rate
                         %averageDR1 = total_R_UE1/((n1-1)*t_symbol+t_symbol/N_RB_persymbol*n2); %update average past data rate
            PF1 = alpha*delay_UE1/UE1_max_delay +(1-alpha)*achievableDR/averageDR1; %scheduling factor
        else
            PF1 = 0;
        end
        if averageDR2 < UE2_Capacity
            delay_UE2 = n1*t_symbol; %current delay
            achievableDR = se*Ns_perRB*B_ss; %achievable data rate
            total_R_UE2 = 0.01+se*Ns_perRB*B_ss*UE2_RB_sd*t_symbol; %total transmitted bits
             averageDR2 = total_R_UE2/(n1*t_symbol); %update average past data rate
                         %averageDR2 = total_R_UE2/((n1-1)*t_symbol+t_symbol/N_RB_persymbol*n2); %update average past data rate
            PF2 = alpha*delay_UE2/UE2_max_delay +(1-alpha)*achievableDR/averageDR2; %scheduling factor
        else
            PF2 = 0;
        end
        if (averageDR1 > UE1_Capacity) && (averageDR2 > UE2_Capacity)
            break
        end
        if PF1 == PF2
            selected_UE(n2,n1) = randi([1,2],1); %select randomly
            if selected_UE(n2,n1) == 1
                UE1_RB_sd = UE1_RB_sd+1; %update number of scheduled RBs for UE1
            else
                UE2_RB_sd = UE2_RB_sd+1; %update number of scheduled RBs for UE2
            end
        elseif PF1 > PF2
            selected_UE(n2,n1) = 1;
            UE1_RB_sd = UE1_RB_sd+1; %update number of scheduled RBs for UE1
        else
            selected_UE(n2,n1) = 2;
            UE2_RB_sd = UE2_RB_sd+1; %update number of scheduled RBs for UE2
        end
        
    end
end

%% Visualization numerology
s = sprintf('UE1 Capacity = %d Mbps,UE2 Capacity = %d Mbps',UE1_Capacity/1e6,UE2_Capacity/1e6);
figure()
imagesc(selected_UE)
xlabel('symbol')
ylabel('RB')
title(s)

UE1_RB_sd
UE2_RB_sd
delay_final_UE1 = delay_UE1*1e3
delay_final_UE2 = delay_UE2*1e3