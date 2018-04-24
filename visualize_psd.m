close all
clear all
clc
addpath(genpath('./biosig')) %adds folder recursively
addpath(genpath('./eeglab_current')) %adds folder recursively
load psd_data.mat
load channel_location_16_10-20_mi.mat

%% Visualizing Emilie's file
% PSD data format
% index = 1 titles
% files 2 - 4 benjamin, 5 - 7 emilie 8 - 10 juraj
% step size of frequencies is 2 because psd file was written in step
% sizes of 2
index = 6;
Freq = 4:2:48;
Beta_frequency = 12:2:30;
[~,Beta_frequency] = intersect(Freq,Beta_frequency);
Mu_frequency = 8:2:12;
[~,Mu_frequency] = intersect(Freq,Mu_frequency);

psd_lap = psd_file{index,3};
psd_car = psd_file{index,2};
events = psd_file{index,4};
psd_lap_feet = squeeze(mean(psd_lap(events ==771, :, :)));
psd_lap_hands = squeeze(mean(psd_lap(events ==773, :, :)));
psd_car_feet = squeeze(mean(psd_car(events ==771, :, :)));
psd_car_hands = squeeze(mean(psd_car(events ==773, :, :)));

figure('color','w')
subplot(2,2,1)
topoplot(squeeze(squeeze(mean( mean(psd_car(events==771,...
    Mu_frequency,...
    :), 1),2 ) )),chanlocs16)
title('\mu Frequency of Car filtered feet ')
subplot(2,2,2)
topoplot(squeeze(squeeze(mean( mean(psd_car(events==773,...
    Mu_frequency,...
    :), 1), 2 ) )),chanlocs16)
title('\mu Frequency of Car filtered Hands ')
subplot(2,2,3)
topoplot(squeeze(squeeze(mean( mean(psd_lap(events==771,...
    Mu_frequency,...
    :), 1),2 ) )),chanlocs16)
title('\mu Frequency of Laplacian filtered feet ')
subplot(2,2,4)
topoplot(squeeze(squeeze(mean( mean(psd_lap(events==773,...
    Mu_frequency,...
    :), 1), 2 ) )),chanlocs16)
title('\mu Frequency of Laplacian filtered Hands ')
% beta frequency
figure('color','w')
subplot(2,2,1)
topoplot(squeeze(squeeze(mean( mean(psd_car(events==771,...
    Beta_frequency,...
    :), 1),2 ) )),chanlocs16)
title('\beta Frequency of Car filtered feet ')
subplot(2,2,2)
topoplot(squeeze(squeeze(mean( mean(psd_car(events==773,...
    Beta_frequency,...
    :), 1), 2 ) )),chanlocs16)
title('\beta Frequency of Car filtered Hands ')
subplot(2,2,3)
topoplot(squeeze(squeeze(mean( mean(psd_lap(events==771,...
    Beta_frequency,...
    :), 1),2 ) )),chanlocs16)
title('\beta Frequency of Laplacian filtered feet ')
subplot(2,2,4)
topoplot(squeeze(squeeze(mean( mean(psd_lap(events==773,...
    Beta_frequency,...
    :), 1), 2 ) )),chanlocs16)
title('\beta Frequency of Laplacian filtered Hands ')

