close all
clear all
clc
addpath(genpath('./biosig')) %adds folder recursively
addpath(genpath('./eeglab_current')) %adds folder recursively
addpath(genpath('./functions'))
load psd_data.mat
load channel_location_16_10-20_mi.mat


%% Average anonymous and topoplots 


[feetCar,handsCar,baselineCar]=separationCar(psd_file);
[feetLap,handsLap,baselineLap]=separationLap(psd_file);

%%% choose a subject between [emily,juraj,benjamin,kriton]
name='benjamin';
j=1;
for i=1:length(psd_file)
    if (strfind(psd_file{i,2},name)==3)
        anonymous_BaselineCAR{j}=baselineCar{1,i};
        anonymous_Feet_CAR{j}=feetCar{1,i};
        anonymous_Hands_CAR{j}=handsCar{1,i};
        anonymous_BaselineLAP{j}=baselineLap{1,i};
        anonymous_Feet_LAP{j}=feetLap{1,i};
        anonymous_Hands_LAP{j}=handsLap{1,i};
        j=j+1;
        
        
    end
end

anonymous_BaselineCAR=log10(vertcat(anonymous_BaselineCAR{:})+1);
anonymous_Feet_CAR=log10(vertcat(anonymous_Feet_CAR{:})+1);
anonymous_Hands_CAR=log10(vertcat(anonymous_Hands_CAR{:})+1);
anonymous_BaselineLAP=log10(vertcat(anonymous_BaselineLAP{:})+1);
anonymous_Feet_LAP=log10(vertcat(anonymous_Feet_LAP{:})+1);
anonymous_Hands_LAP=log10(vertcat(anonymous_Hands_LAP{:})+1);

        
%%%%% For anonymous
% anonymous_BaselineCAR=log10(vertcat(baselineCar{1,32},baselineCar{1,33},baselineCar{1,34},baselineCar{1,35})+1);
% anonymous_Feet_CAR=log10(vertcat(feetCar{1,32},feetCar{1,33},feetCar{1,34},feetCar{1,35})+1);
% anonymous_Hands_CAR=log10(vertcat(handsCar{1,32},handsCar{1,33},handsCar{1,34},handsCar{1,35})+1);
% anonymous_BaselineLAP=log10(vertcat(baselineLap{1,32},baselineLap{1,33},baselineLap{1,34},baselineLap{1,35})+1);
% anonymous_Feet_LAP=log10(vertcat(feetLap{1,32},feetLap{1,33},feetLap{1,34},feetLap{1,35})+1);
% anonymous_Hands_LAP=log10(vertcat(handsLap{1,32},handsLap{1,33},handsLap{1,34},handsLap{1,35})+1);

%%%% Kriton only 4 onlines
% anonymous_BaselineCAR=log10(vertcat(baselineCar{1,24},baselineCar{1,25},baselineCar{1,26},baselineCar{1,27})+1);
% anonymous_Feet_CAR=log10(vertcat(feetCar{1,24},feetCar{1,25},feetCar{1,26},feetCar{1,27})+1);
% anonymous_Hands_CAR=log10(vertcat(handsCar{1,24},handsCar{1,25},handsCar{1,26},handsCar{1,27})+1);
% anonymous_BaselineLAP=log10(vertcat(baselineLap{1,24},baselineLap{1,25},baselineLap{1,26},baselineLap{1,27})+1);
% anonymous_Feet_LAP=log10(vertcat(feetLap{1,24},feetLap{1,25},feetLap{1,26},feetLap{1,27})+1);
% anonymous_Hands_LAP=log10(vertcat(handsLap{1,24},handsLap{1,25},handsLap{1,26},handsLap{1,27})+1);



Freq = 4:2:48;

%%%% Mu Frequencies
Mu_frequency = 10:2:14;
[~,Mu_frequency] = intersect(Freq,Mu_frequency);

% Car


baselineCarMu=squeeze(squeeze(mean(mean(anonymous_BaselineCAR(:,...
    Mu_frequency,...
    :), 1), 2 )));

car_feetMu= squeeze(squeeze(mean(mean(anonymous_Feet_CAR(:,...
    Mu_frequency,...
    :), 1),2 ) ));
car_handsMu = squeeze(squeeze(mean( mean(anonymous_Hands_CAR(:,...
    Mu_frequency,...
    :), 1), 2 ) ));
ERDhandsMuCAR=(car_handsMu-baselineCarMu)./(baselineCarMu);
ERDfeetMuCAR=(car_feetMu-baselineCarMu)./(baselineCarMu);
concMUcar=[ERDhandsMuCAR ; ERDfeetMuCAR];

minimumCARMU=min(concMUcar(:));
maximumCARMU=max(concMUcar(:));
limitsCARMU=[minimumCARMU;maximumCARMU];

figure(1)
topoplot(ERDfeetMuCAR,chanlocs16,'maplimits',limitsCARMU);
colorbar
title('Benjamin: \mu-band of Car filtered Feet ')
saveas(figure(1), 'benjamin_mu_car_feet.png')

figure(2)
topoplot(ERDhandsMuCAR,chanlocs16,'maplimits',limitsCARMU);
colorbar
title('Benjamin: \mu-band of Car filtered Hands ')
saveas(figure(2), 'benjamin_mu_car_hands.png')

% Laplacian

baselineLapMu=squeeze(squeeze(mean(mean(anonymous_BaselineLAP(:,...
    Mu_frequency,...
    :), 1), 2 )));

lap_feetMu= squeeze(squeeze(mean(mean(anonymous_Feet_LAP(:,...
    Mu_frequency,...
    :), 1),2 ) ));
lap_handsMu = squeeze(squeeze(mean( mean(anonymous_Hands_LAP(:,...
    Mu_frequency,...
    :), 1), 2 ) ));
ERDhandsMuLAP=(lap_handsMu-baselineLapMu)./(baselineLapMu);
ERDfeetMuLAP=(lap_feetMu-baselineLapMu)./(baselineLapMu);

concMUlap=[ERDhandsMuLAP;ERDfeetMuLAP];
minimumLAPMU=min(concMUlap(:));
maximumLAPMU=max(concMUlap(:));
limitsLAPMU=[minimumLAPMU;maximumLAPMU];


figure(3)
topoplot(ERDfeetMuLAP,chanlocs16,'maplimits',limitsLAPMU);
colorbar
title('Benjamin: \mu-band of Lap filtered Feet ')
saveas(figure(3), 'benjamin_mu_lap_feet.png')

figure(4)
topoplot(ERDhandsMuLAP,chanlocs16,'maplimits',limitsLAPMU);
colorbar
title('Benjamin: \mu-band of Lap filtered Hands ')
saveas(figure(4), 'benjamin_mu_lap_hands.png')

%%%% beta frequencies

Beta_frequency = 12:2:30;
[~,Beta_frequency] = intersect(Freq,Beta_frequency);

% CAR

baselineCarBeta=squeeze(squeeze(mean(mean(anonymous_BaselineCAR(:,...
    Beta_frequency,...
    :), 1), 2 )));

car_feetBeta= squeeze(squeeze(mean(mean(anonymous_Feet_CAR(:,...
    Beta_frequency,...
    :), 1),2 ) ));
car_handsBeta = squeeze(squeeze(mean( mean(anonymous_Hands_CAR(:,...
    Beta_frequency,...
    :), 1), 2 ) ));
ERDhandsBetaCAR=(car_handsBeta-baselineCarBeta)./(baselineCarBeta);
ERDfeetBetaCAR=(car_feetBeta-baselineCarBeta)./(baselineCarBeta);
concBETAcar=[ERDhandsBetaCAR; ERDfeetBetaCAR];

minimumCARBETA=min(concBETAcar(:));
maximumCARBETA=max(concBETAcar(:));
limitsCARbeta=[minimumCARBETA;maximumCARBETA];

figure(5)
topoplot(ERDfeetBetaCAR,chanlocs16,'maplimits',limitsCARbeta);
colorbar
title('Benjamin: \beta-band of Car filtered Feet ')
saveas(figure(5), 'benjamin_beta_car_feet.png')

figure(6)
topoplot(ERDhandsBetaCAR,chanlocs16,'maplimits',limitsCARbeta);
colorbar
title('Benjamin: \beta-band of Car filtered Hands ')
saveas(figure(6), 'benjamin_beta_car_hands.png')

% Laplacian

baselineLapBeta=squeeze(squeeze(mean(mean(anonymous_BaselineLAP(:,...
    Beta_frequency,...
    :), 1), 2 )));

lap_feetBeta= squeeze(squeeze(mean(mean(anonymous_Feet_LAP(:,...
    Beta_frequency,...
    :), 1),2 ) ));
lap_handsBeta = squeeze(squeeze(mean( mean(anonymous_Hands_LAP(:,...
    Beta_frequency,...
    :), 1), 2 ) ));
ERDhandsBetaLAP=(lap_handsBeta-baselineLapBeta)./(baselineLapBeta);
ERDfeetBetaLAP=(lap_feetBeta-baselineLapBeta)./(baselineLapBeta);

concBETAlap=[ERDhandsBetaLAP;ERDfeetBetaLAP];
minimumLAPBETA=min(concBETAlap(:));
maximumLAPBETA=max(concBETAlap(:));
limitsLAPbeta=[minimumLAPBETA;maximumLAPBETA];


figure(7)
topoplot(ERDfeetBetaLAP,chanlocs16,'maplimits',limitsLAPbeta);
colorbar
title('Benjamin: \beta-band of Lap filtered Feet ')
saveas(figure(7), 'benjamin_beta_lap_feet.png')

figure(8)
topoplot(ERDhandsBetaLAP,chanlocs16,'maplimits',limitsLAPbeta);
colorbar
title('Benjamin: \beta-band of Lap filtered Hands ')
saveas(figure(8), 'benjamin_beta_lap_hands.png')