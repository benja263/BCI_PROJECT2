%% load
addpath(genpath('./biosig')) %adds folder recursively
addpath(genpath('./eeglab_current')) %adds folder recursively
addpath(genpath('./functions')) %adds folder recursively
load psd_data.mat
%% run
tic
freq = 4:2:48;

name = 'kriton';
date = '20180323';

data = day_selector(psd_file,name,date);
exception_times = {'163958','165113'};
[data_for_train, ~] = split_data(data,exception_times);

date = '20180420';
data = day_selector(psd_file,name,date);
[~, data_for_test2] = split_data(data);
data_for_test = [data_for_test; data_for_test2];

% name = 'emily';
% date = '20180326';
% data = day_selector(psd_file,name,date);
% [data_for_train, data_for_test] = split_data(data);

type = 1; % 1 car, 2 lap
Classifier_plotFrequencyMap(data_for_train,type,name,date);
fisher = calculateClassifierFisher(data_for_train,type)';
%fisher = fisher./max(fisher(:));
tol = 0.95*max(fisher(:));
[channels,freq_ind] = find(fisher >= tol);
psd_data = data_for_train{2,type};
tr_events = data_for_train{2,3};
te_events = data_for_test{2,3};
psd_t_data = data_for_test{2,type};
tr_data = [];
te_data = [];
for i = 1:length(channels)
    tr_data = [tr_data, psd_data(:,freq_ind(i),channels(i))];
    te_data = [te_data, psd_t_data(:,freq_ind(i),channels(i))];
end

[tr_data,tr_events] = CleanData(tr_data,tr_events);
[te_data,te_events] = CleanData(te_data,te_events);
n = size(tr_data,1);

Model = fitcdiscr(tr_data,tr_events,'DiscrimType','linear', 'ClassNames',...
    [773,771],'Prior','uniform','OptimizeHyperParameters','all');
[label,post_prob,cost] = predict(Model,te_data);
accuracy = sum(label == te_events) / length(te_events);
Classifier.model = Model;
Classifier.frequencies = freq(freq_ind);
Classifier.channels = channels;
Classifier.type = type; 
load('laplacian_16_10-20_mi.mat');
Classifier.lap = lap;
save('kriton_classifier.mat','Classifier')
toc


