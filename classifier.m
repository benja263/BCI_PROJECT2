%% load
addpath(genpath('./biosig')) %adds folder recursively
addpath(genpath('./eeglab_current')) %adds folder recursively
addpath(genpath('./functions')) %adds folder recursively
load psd_data.mat
%% run
tic
name = 'emily';
date = '20180326';
name = 'benjamin';
date = '20180319';

freq = 4:2:48;
data = day_selector(psd_file,name,date);
[data_for_train, data_for_test] = split_data(data);
type = 1; % 1 car, 2 lap
Classifier_plotFrequencyMap(data_for_train,type,name,date);
fisher = calculateClassifierFisher(data_for_train,type)';
%fisher = fisher./max(fisher(:));
tol = 0.9*max(fisher(:));
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
    {'773','771'},'Prior','uniform');
test_labels = data_for_test{2,3};
post_prob = zeros(2,size(te_data,1));
correct = zeros(1,size(te_data,1));
for i = 1:size(te_data,1)
    test_window = te_data(i,:);
    [label,score,cost] = predict(Model,test_window);
    post_prob(1,i) = score(1); % the classes are inversed in the model
    post_prob(2,i) = score(2);
    if strcmp(label{1},num2str(te_events(i)))
        correct(i) = 1;
    end
end
accuracy = sum(correct)/length(correct);

toc


