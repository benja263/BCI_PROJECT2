%% load
addpath(genpath('./biosig')) %adds folder recursively
addpath(genpath('./eeglab_current')) %adds folder recursively
addpath(genpath('./functions')) %adds folder recursively
%load psd_data.mat



%% Emily Classifier
tic
freq = 4:2:48;

name = 'emily';
date = '20180326';
data = day_selector(psd_file,name,date);
[data_for_train, data_for_test] = split_data(data);
date = '20180430';
data = day_selector(psd_file,name,date);
added_train_trials = {'151410','151929'};
[data_for_train_day2, data_for_test_day2] = split_data(data,added_train_trials);
data_for_train = [data_for_train; data_for_train_day2];
data_for_test = [data_for_test; data_for_test_day2];

type = 1; % 1 car, 2 lap
Classifier_plotFrequencyMap(data_for_train,type,name,date);
fisher = calculateClassifierFisher(data_for_train,type)';

tol = 0.5*max(fisher(:));
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
% 
% Model = fitcdiscr(tr_data,tr_events,'DiscrimType','linear', 'ClassNames',...
%     [773,771],'Prior','uniform','OptimizeHyperParameters','all');
 Model = fitcdiscr(tr_data,tr_events,'DiscrimType','linear', 'ClassNames',...
     [773,771],'Prior','uniform');
[label,post_prob,cost] = predict(Model,te_data);
Conf_mat_emily = confusionmat(label,te_events);
Conf_mat_emily = Conf_mat_emily./(sum(Conf_mat_emily(:)));
emily_accuracy = sum(label == te_events) / length(te_events);
% creating ROC
[X,Y,T,AUC,OPTO] = perfcurve(te_events,post_prob(:,1),'773');
figure('Name','ROC')
plot(X,Y,'b','LineWidth',2)
hold on
grid on
plot(OPTO(1),OPTO(2),'mo');
y_T = find(Y == OPTO(2));
x_T = find(X == OPTO(1));
opt_Threshold = T(intersect(x_T,y_T));
xlabel('False Positive Rate')
ylabel('True Positive Rate')
title({'ROC ';'True Positive = 773';['AUC = ',num2str(AUC)]});
string = ['Optimal Thereshold = ',num2str(opt_Threshold)];
legend('ROC',string)


Classifier.model = Model;
Classifier.frequencies = freq(freq_ind);
Classifier.channels = channels;
Classifier.type = type; 
load('laplacian_16_10-20_mi.mat');
Classifier.lap = lap;
save('emily_classifier.mat','Classifier')
toc
% create class error vs # featuers plot
fisher_vector = fisher(:);
[sorted_fisher_vector,indexes] = sort(fisher_vector,'Descend');
[channels,freq_ind] = ind2sub(size(fisher),indexes);
tr_data = [];
te_data = [];
tr_events = data_for_train{2,3};
te_events = data_for_test{2,3};
nb_features = 120;
for i = 1:nb_features
    tr_data = [tr_data, psd_data(:,freq_ind(i),channels(i))];
    te_data = [te_data, psd_t_data(:,freq_ind(i),channels(i))];
end
[tr_data,tr_events] = CleanData(tr_data,tr_events);
[te_data,te_events] = CleanData(te_data,te_events);
nb_feature_vector = 1:nb_features;
accuracies = zeros(nb_features,1);
for feature = 1:nb_features
    Model = fitcdiscr(tr_data(:,1:feature),tr_events,'DiscrimType','linear', 'ClassNames',...
        [773,771],'Prior','uniform');
    [label,post_prob,cost] = predict(Model,te_data(:,1:feature));
    accuracies(feature) = sum(label == te_events) / length(te_events);
end
figure('Name','Accuracy vs Nb of Features')
plot(nb_feature_vector,accuracies,'b','LineWidth',2)
hold on
grid on
grid minor
xlabel('Number of Features')
ylabel('Accuracy [%]')
ylim([0,1])
title('Emily')
set(gca,'FontSize',16)

%% Kriton Classifier
tic
freq = 4:2:48;
name = 'kriton';
date = '20180323';

data = day_selector(psd_file,name,date);
exception_times = {'163958','165113'};
[data_for_train, data_for_test] = split_data(data);


type = 1; % 1 car, 2 lap
Classifier_plotFrequencyMap(data_for_train,type,name,date);
fisher = calculateClassifierFisher(data_for_train,type)';

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
% 
% Model = fitcdiscr(tr_data,tr_events,'DiscrimType','linear', 'ClassNames',...
%     [773,771],'Prior','uniform','OptimizeHyperParameters','all');
 Model = fitcdiscr(tr_data,tr_events,'DiscrimType','linear', 'ClassNames',...
     [773,771],'Prior','uniform');
[label,post_prob,cost] = predict(Model,te_data);
Conf_mat_kriton = confusionmat(label,te_events);
Conf_mat_kriton = Conf_mat_kriton./(sum(Conf_mat_kriton(:)));
[X,Y,T,AUC,OPTO] = perfcurve(te_events,post_prob(:,1),'773');
figure('Name','ROC')
plot(X,Y,'b','LineWidth',2)
hold on
grid on
plot(OPTO(1),OPTO(2),'mo');
y_T = find(Y == OPTO(2));
x_T = find(X == OPTO(1));
opt_Threshold = T(intersect(x_T,y_T));
xlabel('False Positive Rate')
ylabel('True Positive Rate')
title({'ROC ';'True Positive = 773';['AUC = ',num2str(AUC)]});
string = ['Optimal Thereshold = ',num2str(opt_Threshold)];
legend('ROC',string)

kriton_accuracy = sum(label == te_events) / length(te_events);
Classifier.model = Model;
Classifier.frequencies = freq(freq_ind);
Classifier.channels = channels;
Classifier.type = type; 
load('laplacian_16_10-20_mi.mat');
Classifier.lap = lap;
save('kriton_classifier.mat','Classifier')
toc
% create class error vs # featuers plot
fisher_vector = fisher(:);
[sorted_fisher_vector,indexes] = sort(fisher_vector,'Descend');
[channels,freq_ind] = ind2sub(size(fisher),indexes);
tr_data = [];
te_data = [];
tr_events = data_for_train{2,3};
te_events = data_for_test{2,3};
nb_features = 120;
for i = 1:nb_features
    tr_data = [tr_data, psd_data(:,freq_ind(i),channels(i))];
    te_data = [te_data, psd_t_data(:,freq_ind(i),channels(i))];
end
[tr_data,tr_events] = CleanData(tr_data,tr_events);
[te_data,te_events] = CleanData(te_data,te_events);
nb_feature_vector = 1:nb_features;
accuracies = zeros(nb_features,1);
for feature = 1:nb_features
    Model = fitcdiscr(tr_data(:,1:feature),tr_events,'DiscrimType','linear', 'ClassNames',...
        [773,771],'Prior','uniform');
    [label,post_prob,cost] = predict(Model,te_data(:,1:feature));
    accuracies(feature) = sum(label == te_events) / length(te_events);
end
figure('Name','Accuracy vs Nb of Features')
plot(nb_feature_vector,accuracies,'b','LineWidth',2)
hold on
grid on
grid minor
xlabel('Number of Features')
ylabel('Accuracy [%]')
ylim([0,1])
title('Kriton')
set(gca,'FontSize',16)

%% Juraj
tic
freq = 4:2:48;
name = 'juraj';
date = '20180326';

data = day_selector(psd_file,name,date);
[data_for_train, data_for_test] = split_data(data);

type = 1; % 1 car, 2 lap
Classifier_plotFrequencyMap(data_for_train,type,name,date);
fisher = calculateClassifierFisher(data_for_train,type)';

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
% 
% Model = fitcdiscr(tr_data,tr_events,'DiscrimType','linear', 'ClassNames',...
%     [773,771],'Prior','uniform','OptimizeHyperParameters','all');
 Model = fitcdiscr(tr_data,tr_events,'DiscrimType','linear', 'ClassNames',...
     [773,771],'Prior','uniform');
[label,post_prob,cost] = predict(Model,te_data);
Conf_mat_juraj = confusionmat(label,te_events); 
Conf_mat_juraj = Conf_mat_juraj./(sum(Conf_mat_juraj(:)));
[X,Y,T,AUC,OPTO] = perfcurve(te_events,post_prob(:,1),'773');
figure('Name','ROC')
plot(X,Y,'b','LineWidth',2)
hold on
grid on
plot(OPTO(1),OPTO(2),'mo');
y_T = find(Y == OPTO(2));
x_T = find(X == OPTO(1));
opt_Threshold = T(intersect(x_T,y_T));
xlabel('False Positive Rate')
ylabel('True Positive Rate')
title({'ROC ';'True Positive = 773';['AUC = ',num2str(AUC)]});
string = ['Optimal Thereshold = ',num2str(opt_Threshold)];
legend('ROC',string)

juraj_accuracy = sum(label == te_events) / length(te_events);
Classifier.model = Model;
Classifier.frequencies = freq(freq_ind);
Classifier.channels = channels;
Classifier.type = type; 
load('laplacian_16_10-20_mi.mat');
Classifier.lap = lap;

save('juraj_classifier.mat','Classifier')


toc
% create class error vs # featuers plot
fisher_vector = fisher(:);
[sorted_fisher_vector,indexes] = sort(fisher_vector,'Descend');
[channels,freq_ind] = ind2sub(size(fisher),indexes);
tr_data = [];
te_data = [];
tr_events = data_for_train{2,3};
te_events = data_for_test{2,3};
nb_features = 120;
for i = 1:nb_features
    tr_data = [tr_data, psd_data(:,freq_ind(i),channels(i))];
    te_data = [te_data, psd_t_data(:,freq_ind(i),channels(i))];
end
[tr_data,tr_events] = CleanData(tr_data,tr_events);
[te_data,te_events] = CleanData(te_data,te_events);
nb_feature_vector = 1:nb_features;
accuracies = zeros(nb_features,1);
for feature = 1:nb_features
    Model = fitcdiscr(tr_data(:,1:feature),tr_events,'DiscrimType','linear', 'ClassNames',...
        [773,771],'Prior','uniform');
    [label,post_prob,cost] = predict(Model,te_data(:,1:feature));
    accuracies(feature) = sum(label == te_events) / length(te_events);
end
figure('Name','Accuracy vs Nb of Features')
plot(nb_feature_vector,accuracies,'b','LineWidth',2)
hold on
grid on
grid minor
xlabel('Number of Features')
ylabel('Accuracy [%]')
ylim([0,1])
title('Juraj')
set(gca,'FontSize',16)

%% Benjamin
freq = 4:2:48;
name = 'benjamin';
date = '20180319';

data = day_selector(psd_file,name,date);

[data_for_train, data_for_test] = split_data(data);


type = 1; % 1 car, 2 lap
Classifier_plotFrequencyMap(data_for_train,type,name,date);
fisher = calculateClassifierFisher(data_for_train,type)';

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
% 
% Model = fitcdiscr(tr_data,tr_events,'DiscrimType','linear', 'ClassNames',...
%     [773,771],'Prior','uniform','OptimizeHyperParameters','all');
 Model = fitcdiscr(tr_data,tr_events,'DiscrimType','linear', 'ClassNames',...
     [773,771],'Prior','uniform');
[label,post_prob,cost] = predict(Model,te_data);
Conf_mat_benja = confusionmat(label,te_events); 
Conf_mat_benja = Conf_mat_benja./(sum(Conf_mat_benja(:)));
[X,Y,T,AUC,OPTO] = perfcurve(te_events,post_prob(:,1),'773');
figure('Name','ROC')
plot(X,Y,'b','LineWidth',2)
hold on
grid on
plot(OPTO(1),OPTO(2),'mo');
y_T = find(Y == OPTO(2));
x_T = find(X == OPTO(1));
opt_Threshold = T(intersect(x_T,y_T));
xlabel('False Positive Rate')
ylabel('True Positive Rate')
title({'ROC ';'True Positive = 773';['AUC = ',num2str(AUC)]});
string = ['Optimal Thereshold = ',num2str(opt_Threshold)];
legend('ROC',string)
benja_accuracy = sum(label == te_events) / length(te_events);
Classifier.model = Model;
Classifier.frequencies = freq(freq_ind);
Classifier.channels = channels;
Classifier.type = type; 
load('laplacian_16_10-20_mi.mat');
Classifier.lap = lap;
save('benjamin_classifier.mat','Classifier')
toc
% create class error vs # featuers plot
fisher_vector = fisher(:);
[sorted_fisher_vector,indexes] = sort(fisher_vector,'Descend');
[channels,freq_ind] = ind2sub(size(fisher),indexes);
tr_data = [];
te_data = [];
tr_events = data_for_train{2,3};
te_events = data_for_test{2,3};
nb_features = 120;
for i = 1:nb_features
    tr_data = [tr_data, psd_data(:,freq_ind(i),channels(i))];
    te_data = [te_data, psd_t_data(:,freq_ind(i),channels(i))];
end
[tr_data,tr_events] = CleanData(tr_data,tr_events);
[te_data,te_events] = CleanData(te_data,te_events);
nb_feature_vector = 1:nb_features;
accuracies = zeros(nb_features,1);
for feature = 1:nb_features
    Model = fitcdiscr(tr_data(:,1:feature),tr_events,'DiscrimType','linear', 'ClassNames',...
        [773,771],'Prior','uniform');
    [label,post_prob,cost] = predict(Model,te_data(:,1:feature));
    accuracies(feature) = sum(label == te_events) / length(te_events);
end
figure('Name','Accuracy vs Nb of Features')
plot(nb_feature_vector,accuracies,'b','LineWidth',2)
hold on
grid on
grid minor
xlabel('Number of Features')
ylabel('Accuracy [%]')
ylim([0,1])
title('Benjamin')
set(gca,'FontSize',16)