close all
clear all
clc
addpath(genpath('./biosig')) %adds folder recursively
addpath(genpath('./eeglab_current')) %adds folder recursively
load psd_data.mat
load channel_location_16_10-20_mi.mat


%% Average anonymous and topoplots 

[feetCar,handsCar,baselineCar]=separationCar(psd_file);
[feetLap,handsLap,baselineLap]=separationLap(psd_file);

% anonymous_BaselineCAR=log10(vertcat(baselineCar{1,2},baselineCar{1,33},baselineCar{1,34},baselineCar{1,35})+1);
% anonymous_Feet_CAR=log10(vertcat(feetCar{1,2},feetCar{1,33},feetCar{1,34},feetCar{1,35})+1);
% anonymous_Hands_CAR=log10(vertcat(handsCar{1,2},handsCar{1,33},handsCar{1,34},handsCar{1,35})+1);
% anonymous_BaselineLAP=log10(vertcat(baselineLap{1,2},baselineLap{1,33},baselineLap{1,34},baselineLap{1,35})+1);
% anonymous_Feet_LAP=log10(vertcat(feetLap{1,2},feetLap{1,33},feetLap{1,34},feetLap{1,35})+1);
% anonymous_Hands_LAP=log10(vertcat(handsLap{1,2},handsLap{1,33},handsLap{1,34},handsLap{1,35})+1);

anonymous_BaselineCAR=log10(baselineCar{1,36}+1);
anonymous_Feet_CAR=log10(feetCar{1,36}+1);
anonymous_Hands_CAR=log10(handsCar{1,36}+1);
anonymous_BaselineLAP=log10(baselineLap{1,36}+1);
anonymous_Feet_LAP=log10(feetLap{1,36}+1);
anonymous_Hands_LAP=log10(handsLap{1,36}+1);

Freq = 4:2:48;

% Car
Mu_frequency = 10:2:14;
[~,Mu_frequency] = intersect(Freq,Mu_frequency);

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

figure

subplot(2,2,1)

topoplot(ERDfeetMuCAR,chanlocs16,'maplimits','maxmin');
colorbar
title('\mu Frequency of Car filtered feet ')

subplot(2,2,2)

topoplot(ERDhandsMuCAR,chanlocs16,'maplimits','maxmin');
colorbar
title('\mu Frequency of Car filtered Hands ')

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
ERDhandsMu=(lap_handsMu-baselineLapMu)./(baselineLapMu);
ERDfeetMu=(lap_feetMu-baselineLapMu)./(baselineLapMu);


subplot(2,2,3)
topoplot(ERDfeetMu,chanlocs16,'maplimits','maxmin');
colorbar
title('\mu Frequency of Lap filtered feet ')

subplot(2,2,4)
topoplot(ERDhandsMu,chanlocs16,'maplimits','maxmin');
colorbar
title('\mu Frequency of Lap filtered Hands ')


%% Preprocessing

index=33; 

Freq = 4:2:48;
Beta_frequency = 12:2:30;
[~,Beta_frequency] = intersect(Freq,Beta_frequency);
Mu_frequency = 10:2:14;
[~,Mu_frequency] = intersect(Freq,Mu_frequency);

lpsd_lap = log10(psd_file{index,4}+1);
lpsd_car = log10(psd_file{index,3}+1);
events = psd_file{index,5};


%% Topoplots

fig = figure('color','w');
name = psd_file{index,2};
if length(name) > 3
    user = strsplit(name,'/');
    user = [user{2},' ', user{3}];
else
    user = 'anonymous';
end
set(fig,'Name',user)
subplot(2,2,1)
baselineCarMu=squeeze(squeeze(mean(mean(lpsd_car(events==786,...
    Mu_frequency,...
    :), 1), 2 )));
car_feetMu= squeeze(squeeze(mean(mean(lpsd_car(events==771,...
    Mu_frequency,...
    :), 1),2 ) ));
car_handsMu = squeeze(squeeze(mean( mean(lpsd_car(events==773,...
    Mu_frequency,...
    :), 1), 2 ) ));
ERDhandsMu=(car_handsMu-baselineCarMu)./(baselineCarMu);
ERDfeetMu=(car_feetMu-baselineCarMu)./(baselineCarMu);

topoplot(ERDfeetMu,chanlocs16,'maplimits','maxmin');
colorbar
title('\mu Frequency of Car filtered feet ')
subplot(2,2,2)

topoplot(ERDhandsMu,chanlocs16,'maplimits','maxmin');
colorbar
title('\mu Frequency of Car filtered Hands ')


subplot(2,2,3)
baselineLapMu=squeeze(squeeze(mean(mean(lpsd_lap(events==786,...
    Mu_frequency,...
    :), 1), 2 )));
lap_feetMu = squeeze(squeeze(mean( mean(lpsd_lap(events==771,...
    Mu_frequency,...
    :), 1),2 ) ));
ERDfeetlapMu=(lap_feetMu-baselineLapMu)./(baselineLapMu);
topoplot(ERDfeetlapMu,chanlocs16,'maplimits','maxmin');
colorbar
title('\mu Frequency of Laplacian filtered feet ')
subplot(2,2,4)
lap_handsMu = squeeze(squeeze(mean( mean(lpsd_lap(events==773,...
    Mu_frequency,...
    :), 1), 2 ) ));
ERDhandslapMu=(lap_handsMu-baselineLapMu)./(baselineLapMu);
topoplot(ERDhandslapMu,chanlocs16,'maplimits','maxmin');
colorbar
title('\mu Frequency of Laplacian filtered Hands ')

% beta frequency
figure('color','w')
subplot(2,2,1)
baselineCarB=squeeze(squeeze(mean(mean(lpsd_car(events==786,...
    Beta_frequency,...
    :), 1), 2 )));
car_feetB = squeeze(squeeze(mean(mean(lpsd_car(events==771,...
    Beta_frequency,...
    :), 1),2 ) ));
car_handsB = squeeze(squeeze(mean( mean(lpsd_car(events==773,...
    Beta_frequency,...
    :), 1), 2 ) ));
ERDhandsCarB=(car_handsB-baselineCarB)./(baselineCarB);
ERDfeetCarB=(car_feetB-baselineCarB)./(baselineCarB);

topoplot(ERDfeetCarB,chanlocs16,'maplimits','maxmin');
colorbar
title('\beta Frequency of Car filtered feet ')
subplot(2,2,2)

topoplot(ERDhandsCarB,chanlocs16,'maplimits','maxmin');
colorbar
title('\beta Frequency of Car filtered Hands ')


subplot(2,2,3)
baselineLapB=squeeze(squeeze(mean(mean(lpsd_lap(events==786,...
    Beta_frequency,...
    :), 1), 2 )));
lap_feetB = squeeze(squeeze(mean( mean(lpsd_lap(events==771,...
    Beta_frequency,...
    :), 1),2 ) ));
ERDfeetlapB=(lap_feetB-baselineLapB)./(baselineLapB);
topoplot(ERDfeetlapB,chanlocs16,'maplimits','maxmin');
colorbar
title('\beta Frequency of Laplacian filtered feet ')
subplot(2,2,4)
lap_handsB = squeeze(squeeze(mean( mean(lpsd_lap(events==773,...
    Beta_frequency,...
    :), 1), 2 ) ));
ERDhandslapB=(lap_handsB-baselineLapB)./(baselineLapB);
topoplot(ERDhandslapB,chanlocs16,'maplimits','maxmin');
colorbar
title('\beta Frequency of Laplacian filtered Hands ')
%% plotting individuals offline  features
names = {'./benjamin/offline/','./emily/offline/','./kriton/offline/'...
    './juraj/offline/','./'};
type = 3; % car is 3, laplacian is 4

for i = 1:length(names)
    if i == 3
        size = [2,1];
    else
        size = [3,2];
    end
    plotFrequencyMap(names{i},size,psd_file,type)
end

%% plotting individuals online  features
names = {'./benjamin/online/','./emily/online/','./kriton/online/'...
    './juraj/online/'};
type = 4; % car is 3, laplacian is 4
for i = 1:length(names)
    if i == 1
        size = [4,2];
    elseif i == 3
        size = [3,2];
    else
        size = [2,2];
    end
    plotFrequencyMap(names{i},size,psd_file,type);
end


function plotFrequencyMap(name,size,psd_file,type)
    % type is laplacian or CAR filtering
    % 3 for car, 4 for laplacian
    
    ind = 1;
    figure('color','w');
    if type == 3
        text = 'CAR';
    elseif type == 4
        text = 'Laplacian';
    else
        disp('Error Type can only be 3 for CAR or 4 for Laplacian')
        return
    end
    
    if length(name) > 3
        user = strsplit(name,'/');
        user = [user{2},' ', user{3}];
    else
        user = 'annonymous';
    end

    for i=1:length(psd_file)
        if strcmp(name,psd_file{i,2})
            subplot_tight(size(1),size(2),ind,[0.1,0.1])
            heat_map = calculateFisher(type,psd_file,i)';
            heat_map = heat_map./max(heat_map(:));
            imagesc(heat_map);
            title(psd_file{i,1});
            ylabel('Channels');
            xlabel('Frequencies [Hz]');
            xticklabels(4:2:48);
            ind = ind + 1;
            colorbar;
            set(gca,'FontSize',16);
            set(gca,'XTick', 1:1:23);
            set(gca,'YTick',2:2:16);
        end
    end
    string = [user, ' feature discriminability using ', text, ' filtering'];
    h = suplabel(string,'t');
    set(h,'FontSize',16)

    

end

function psd = calculateFisher(type,psd_file,index)
    psd = psd_file{index,type};
    events = psd_file{index,5};
    psd_left_std=squeeze(std(psd(events ==771, :, :)));
    psd_left_mean = squeeze(mean(psd(events ==771, :, :)));
    psd_right_std = squeeze(std(psd(events ==773, :, :)));
    psd_right_mean = squeeze(mean(psd(events ==773, :, :)));
    psd = (abs(psd_left_mean-psd_right_mean))...
        ./(sqrt(psd_left_std.^2+psd_right_std.^2));
    psd = psd.^2;
end