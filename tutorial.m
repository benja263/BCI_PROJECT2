% addpath(genpath('path')) adds folder recursively
[s, h] = sload('anonymous.20170613.161402.offline.mi.mi_bhbf.gdf');

% s is actual data in form: samples X channels; 17th channel empty - to be removed
% h is header of the file
% h.EVENT.TYP - for corresponding event to the code see slides
% h.EVENT.POS - position (timestamp) of the event
% h.EVENT.DUR - duration on how long the given event lasted
% h.EVENT.SampleRate

data = [h.EVENT.TYP, h.EVENT.POS, h.EVENT.DUR];

start_positions = h.EVENT.POS(h.EVENT.TYP==771);
stop_positions = start_positions + h.EVENT.DUR(h.EVENT.TYP==771) - 1;

% hex2dec('30d')
event_id_cf = 781;
start_positions_cf = h.EVENT.POS(h.EVENT.TYP==event_id_cf);
stop_positions_cf = start_positions_cf + h.EVENT.DUR(h.EVENT.TYP==event_id_cf) - 1;
num_trials = length(start_positions_cf);
num_channles = size(s,2) - 1;

% cf_data = zeros(sum(h.EVENT.DUR(h.EVENT.TYP==event_id_cf)),num_channles);
signal_length = min(unique(h.EVENT.DUR(h.EVENT.TYP==event_id_cf)));
cf_data = zeros(signal_length, num_channles, num_trials);
% Epoching
for trial_id = 1: num_trials
   cf_start = start_positions_cf(trial_id); 
   cf_stop = stop_positions_cf(trial_id); 
%    disp(['Continuous feedback for trial' num2str(trial_id) ' starts at ' num2str(cf_start) ' and ends at ' num2str(cf_stop)])
   cf_data(:, :, trial_id) = s(cf_start : cf_start + signal_length - 1, 1:num_channles);
end

plot(start_positions_cf)

% sample rate
h.SampleRate

% duration of experiment in s
size(s, 1) / h.SampleRate

% event related to que (left/right)
trial_label = h.EVENT.TYP(h.EVENT.TYP == 771 | h.EVENT.TYP == 773);

% channel 9 - Cz - cental channel
figure
subplot(1, 2, 1)
% 9th channel, left que (771), mean over all such events
avg_class1 = mean(cf_data(:, 9, trial_label==771), 3);
plot(avg_class1);
title('Channel Cz (9) - Class 771');
xlabel('sample');
ylabel('\muV');
subplot(1, 2, 2)
% 9th channel, right que (773), mean over all such events
avg_class1 = mean(cf_data(:, 9, trial_label==773), 3);
plot(avg_class1);
title('Channel Cz (9) - Class 773');
xlabel('sample');
ylabel('\muV');

% filtering
% doc filter
% FIR/IIR
% a, b according to what kind of filter we want - e.g. Butterworth, Chebyshev
% help butter
% bandpass filter - Butterworth, order 4, 8Hz - 12Hz, need to divide by
% sampling frequency to get normalized frequencies (why divide by 2?)
% [b a] = butter(4,[8 12] * 2 / h.SampleRate);
% h = fvtool(b,a); % unstable filter - frequncy respons is not flat
% zoom in to frezuency of interest (Analysis -> Sampling Frequency for real freqs.)
[b a] = butter(2,[8 12] * 2 / h.SampleRate);
h = fvtool(b,a); % stable filter

data = cf_data(:, 9, 1);
data_filtered = filter(b, a, data);
figure
plot(data)
hold on
plot(data_filtered)
hold off
% filter whole file and then epoch data - can't be done on realtime data

% 
% cf_data_ga = mean(cf_data, 3);
% 
% figure
% plot(cf_data_ga);
% 
% 
% figure
% for i = 1 : num_channles
%    subplot(4, 4, i);
%    plot(cf_data_ga(:, i));
%    xlim([1 signal_length]);
%    title(['Channel ', num2str(i)]);
% end





