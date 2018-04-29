close all
clear all
clc
addpath(genpath('./biosig')) %adds folder recursively
addpath(genpath('./eeglab_current')) %adds folder recursively
load psd_data.mat
load channel_location_16_10-20_mi.mat

%% Preprocessing

index=29; 
Freq = 4:2:48;
Beta_frequency = 12:2:30;
[~,Beta_frequency] = intersect(Freq,Beta_frequency);
Mu_frequency = 8:2:12;
[~,Mu_frequency] = intersect(Freq,Mu_frequency);

psd_lap = psd_file{index,4};
psd_car = psd_file{index,3};
events = psd_file{index,5};

%% Topoplots

figure('color','w')
subplot(2,2,1)
topoplot(squeeze(squeeze(mean( mean(psd_car(events==771,...
    Mu_frequency,...
    :), 1),2 ) )),chanlocs16);
title('\mu Frequency of Car filtered feet ')
subplot(2,2,2)
topoplot(squeeze(squeeze(mean( mean(psd_car(events==773,...
    Mu_frequency,...
    :), 1), 2 ) )),chanlocs16);
title('\mu Frequency of Car filtered Hands ')
subplot(2,2,3)
topoplot(squeeze(squeeze(mean( mean(psd_lap(events==771,...
    Mu_frequency,...
    :), 1),2 ) )),chanlocs16);
title('\mu Frequency of Laplacian filtered feet ')
subplot(2,2,4)
topoplot(squeeze(squeeze(mean( mean(psd_lap(events==773,...
    Mu_frequency,...
    :), 1), 2 ) )),chanlocs16);
title('\mu Frequency of Laplacian filtered Hands ')
% beta frequency
figure('color','w')
subplot(2,2,1)
topoplot(squeeze(squeeze(mean( mean(psd_car(events==771,...
    Beta_frequency,...
    :), 1),2 ) )),chanlocs16);
title('\beta Frequency of Car filtered feet ')
subplot(2,2,2)
topoplot(squeeze(squeeze(mean( mean(psd_car(events==773,...
    Beta_frequency,...
    :), 1), 2 ) )),chanlocs16);
title('\beta Frequency of Car filtered Hands ')
subplot(2,2,3)
topoplot(squeeze(squeeze(mean( mean(psd_lap(events==771,...
    Beta_frequency,...
    :), 1),2 ) )),chanlocs16);
title('\beta Frequency of Laplacian filtered feet ')
subplot(2,2,4)
topoplot(squeeze(squeeze(mean( mean(psd_lap(events==773,...
    Beta_frequency,...
    :), 1), 2 ) )),chanlocs16);
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
            subplot(size(1),size(2),ind)
            heat_map = calculateFisher(type,psd_file,i)';
            heat_map = heat_map./max(heat_map(:));
            imagesc(heat_map);
            title(psd_file{i,1})
            ylabel('Channels')
            xlabel('Frequencies [Hz]')
            xticklabels(4:2:48);
            ind = ind + 1;
            colorbar
            set(gca,'FontSize',16)
            set(gca,'XTick', 0:2:44)
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
    psd = (abs(psd_left_mean-psd_right_mean))...
        ./(sqrt(psd_left_std.^2+psd_right_std.^2));
    psd = psd.^2;
end