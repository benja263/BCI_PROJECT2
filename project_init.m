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

% motor imagery is in mu frequency band or beta fequency band -> 2 filters

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
% should be done only on one trial, continuous feedback and one class (both hands or both feet)
mean_mu = mean(data_mu, 2);
mean_beta = mean(data_beta, 2);

car_mu = s - repmat(mean_mu, 1, 16);
car_beta = s - repmat(mean_beta, 1, 16);

left_data = data(data(:, 1)==771, :);
left_start_positions = left_data(:, 2);
left_stop_positions = left_start_positions +  left_data(:, 3) - 1;

right_data = data(data(:, 1)==773, :);
right_start_positions = right_data(:, 2);
right_stop_positions = right_start_positions +  right_data(:, 3) - 1;

sample_no = left_start_positions(1);
load channel_location_16_10-20_mi.mat
figure
topoplot(car_mu(sample_no, :), chanlocs16);
figure
topoplot(car_beta(sample_no, :), chanlocs16);

% small laplacian - local artifacts
% use lap matrix and matrix multiplication
load laplacian_16_10-20_mi.mat

lap_mu=s(left_start_positions:...
    left_stop_positions,:)*lap;
lap_beta=s(left_start_positions:...
    left_stop_positions,:)*lap;
right_lap_mu=s(right_start_positions:...
    right_stop_positions,:)*lap;
right_lap_beta=s(right_start_positions:...
    right_stop_positions,:)*lap;
figure
topoplot(lap_beta(2,:),chanlocs16);
figure
topoplot(lap_mu(2,:),chanlocs16);

% psd to extract power of the signal for each frequency
% pwelch
% should behave according to power law (1/F)
[pxx_left, f] = pwelch(lap_mu(:, 8:12), 256, 256/2, [8 9 10 11 12], 512); % do it only 
% figure
% pwelch(lap_beta(:, 8:12), 256, 256/2, [], 512); 
[pxx_right, f] = pwelch(right_lap_mu(:, 8:12), 256, 256/2, [8 9 10 11 12], 512); % do it only 
% figure
% pwelch(right_lap_beta(:, 8:12), 256, 256/2, [], 512);

% online, pwelch for each window (1 second long) -> buffer -> if full -> pwelch 62.5ms 16Hz
% power and log on filtered signal

% moving average filter
a = 2;
b = [1/3 1/3 1/3];
moving_average_mu = filter(b,a,data_mu(left_start_positions:...
    left_stop_positions,:));
moving_average_beta = filter(b,a,data_beta(left_start_positions:...
    left_stop_positions,:));

