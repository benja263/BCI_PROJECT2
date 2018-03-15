addpath(genpath('./biosig')) %adds folder recursively
addpath(genpath('./eeglab_current')) %adds folder recursively

[s1, h1] = sload('anonymous.20170613.161402.offline.mi.mi_bhbf.gdf'); %1
[s2, h2] = sload('anonymous.20170613.162331.offline.mi.mi_bhbf.gdf'); %2
[s3, h3] = sload('anonymous.20170613.162934.offline.mi.mi_bhbf.gdf'); %3
% [s4, h4] = sload('anonymous.20170613.170929.online.mi.mi_bhbf.ema.gdf');

% sample x channel matrix
% fix start positions
% label of file
% for the beginning only offline files

s = [s1; s2; s3];
sample_to_file = [ones(size(s1, 1), 1); 2 * ones(size(s2, 1), 1); 3 * ones(size(s3, 1), 1)];

data = [[h1.EVENT.TYP; h2.EVENT.TYP; h3.EVENT.TYP;], [h1.EVENT.POS; h2.EVENT.POS + size(s1,1); h3.EVENT.POS + size(s1,1) + size(s2,1)], [h1.EVENT.DUR; h2.EVENT.DUR; h3.EVENT.DUR]];

plot(data(:, 2))
% jumps because each trial has some delay in the beginning

% motor imagery is in mju frequency band or beta fequency band -> 2 filters

[b1 a1] = butter(4,[7.5 12.5] * 2 / h1.SampleRate);
h = fvtool(b1,a1); % stable filter

s = s(:, 1:16);

data_mu = filter(b1, a1, s);
% figure
% plot(data)
% hold on
% plot(data_filtered)
% hold off

[b2 a2] = butter(2,[12.5 30] * 2 / h1.SampleRate);
h = fvtool(b2,a2); % stable filter

data_beta = filter(b2, a2, s);

% % creates the filters
% H1=dfilt.df2t(b1,a1);
% H2=dfilt.df2t(b2,a2);
% % creates the cascate filter
% Hcas=dfilt.cascade(H1,H2);
% fvtool(Hcas);

% CAR - gloabal artifacts
% wrong so far -> should be done only on one trial, continuous feedback and
% one class (both hands or both feet)
mean_mu = mean(data_mu, 2);
mean_beta = mean(data_beta, 2);

car_mu = s - repmat(mean_mu, 1, 16);
car_beta = s - repmat(mean_beta, 1, 16);

load channel_location_16_10-20_mi.mat
figure
topoplot(car_mu(1, :), chanlocs16);
figure
topoplot(car_beta(1, :), chanlocs16);

% small laplacian - local artifacts
% use lap matrix and matrix multiplication
load laplacian_16_10-20_mi.mat
