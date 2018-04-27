close all
clear all
clc
addpath(genpath('./biosig')) %adds folder recursively
addpath(genpath('./eeglab_current')) %adds folder recursively
load psd_data.mat
load channel_location_16_10-20_mi.mat

%% Visualizing files
% PSD data format
% index = 1 titles
% files 2 - 4 benjamin, 5 - 7 emilie 8 - 10 juraj
% step size of frequencies is 2 because psd file was written in step
% sizes of 2
index = 20;
Freq = 4:2:48;
Beta_frequency = 12:2:30;
[~,Beta_frequency] = intersect(Freq,Beta_frequency);
Mu_frequency = 8:2:12;
[~,Mu_frequency] = intersect(Freq,Mu_frequency);

psd_lap = psd_file{index,4};
psd_car = psd_file{index,3};
events = psd_file{index,5};

%%%%Calculate Fisher score 

psd_lap_feet_std=squeeze(std(psd_lap(events ==771, :, :)));
psd_lap_feet_mean = squeeze(mean(psd_lap(events ==771, :, :)));
psd_lap_hands_std = squeeze(std(psd_lap(events ==773, :, :)));
psd_lap_hands_mean = squeeze(mean(psd_lap(events ==773, :, :)));
psd_lap_fisher=(abs(psd_lap_feet_mean-psd_lap_hands_mean))./(sqrt(psd_lap_feet_std.^2+psd_lap_hands_std.^2));



psd_car_feet_mean = squeeze(mean(psd_car(events ==771, :, :))); % take the mean of all the windows that 
% belong to event 771(feet), for all channels 
psd_car_feet_std=squeeze(std(psd_car(events ==771, :, :)));
psd_car_hands_mean = squeeze(mean(psd_car(events ==773, :, :)));
psd_car_hands_std = squeeze(std(psd_car(events ==773, :, :)));
psd_car_fisher=(abs(psd_car_feet_mean-psd_car_hands_mean))./(sqrt(psd_car_feet_std.^2+psd_car_hands_std.^2));

%%%%Plot feature discriminability 
figure

subplot(2,1,1)
imagesc(psd_car_fisher') % we want frequencies in X
title('Feature Discriminability using CAR filtering')
ylabel('Channels')
xlabel('Frequences [Hz]')

subplot(2,1,2)
imagesc(psd_lap_fisher')
title('Feature Discriminability using Laplacian filtering')
ylabel('Channels')
xlabel('Frequences[Hz]')




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

%% plotting individuals offline  features
names = {'./benjamin/offline/','./emily/offline/','./kriton/offline/'...
    './juraj/offline/','./'};
type = 4; % car is 3, laplacian is 4

for i = 1:length(names)
    if i == 3
        size = [2,1];
    else
        size = [2,2];
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
    plotFrequencyMap(names{i},size,psd_file,type)
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
            subplot(size(1),size(2),ind)
            imagesc(calculateFisher(type,psd_file,i)')
            ylabel('Channels')
            xlabel('Frequencies [Hz]')
            ind = ind + 1;
            colorbar
            set(gca,'FontSize',16)
            set(gca,'XTick', 2:2:48)
            set(gca,'YTick',2:2:16)
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
    psd =(abs(psd_left_mean-psd_right_mean))...
        ./(sqrt(psd_left_std.^2+psd_right_std.^2));
end