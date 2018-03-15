% addpath(genpath('path')) adds folder recursively
clear all
addpath(genpath('/Users/benjaminfuhrer/Downloads/BCI/biosig'))
addpath(genpath('/Users/benjaminfuhrer/Downloads/BCI/Project 2 - Naturally controlling a MI BCI-driven robot-20180308'))

[s, h] = sload('anonymous.20170613.161402.offline.mi.mi_bhbf.gdf');
[s2, h2] = sload('anonymous.20170613.162331.offline.mi.mi_bhbf.gdf');
[s3, h3] = sload('anonymous.20170613.162934.offline.mi.mi_bhbf.gdf');

label_vector = ones(size(s,1),1);
label_vector = vertcat(label_vector,(ones(size(s2,1),1)+1));
label_vector = vertcat(label_vector,(ones(size(s3,1),1)+2));
s_matrix = vertcat(s,s2);
s_matrix = vertcat(s_matrix,s3);

% s is actual data in form: samples X channels; 17th channel empty - to be removed
% h is header of the file
% h.EVENT.TYP - for corresponding event to the code see slides
% h.EVENT.POS - position (timestamp) of the event
% h.EVENT.DUR - duration on how long the given event lasted
% h.EVENT.SampleRate
type = h.EVENT.TYP;
duration = h.EVENT.DUR;
position = h.EVENT.POS;
type = vertcat(type,h2.EVENT.TYP);
type = vertcat(type,h3.EVENT.TYP);
duration = vertcat(duration,h2.EVENT.DUR);
duration = vertcat(duration,h3.EVENT.DUR);
position = vertcat(position,h2.EVENT.POS + position(end));
position = vertcat(position,h3.EVENT.POS + position(end));
figure
plot(s_matrix(:,1))
hold on
[bmu,amu] = butter(4,[7.5 12.5]/512*2,'bandpass');
filteredmu_data=filter(bmu,amu,s_matrix(:,1));
plot(filteredmu_data)
[b_beta,a_beta] = butter(4,[12.5 30]/512/2,'bandpass');
filteredbeta_data=filter(b_beta,a_beta,s_matrix(:,1));
start_positions = h.EVENT.POS(h.EVENT.TYP==771);
stop_positions = start_positions + h.EVENT.DUR(h.EVENT.TYP==771) - 1;

% hex2dec('30d')
event_id_cf = 781;
start_positions_cf = h.EVENT.POS(h.EVENT.TYP==event_id_cf);
stop_positions_cf = start_positions_cf + h.EVENT.DUR(h.EVENT.TYP==event_id_cf) - 1;
num_trials = length(start_positions_cf);
num_channels = size(s,2) -1;
min_duration = min(h.EVENT.DUR(h.EVENT.TYP == event_id_cf));
Epoch = zeros(min_duration, num_channels , num_trials);
% epoch

for trial_id = 1: num_trials
   cf_start = start_positions_cf(trial_id); 
   cf_stop = cf_start + size(Epoch, 1) -1; 
   disp(['Continuous feedback for trial' num2str(trial_id) ' starts at ' num2str(cf_start) ' and ends at ' num2str(cf_stop)])
   Epoch(:,:,trial_id) = s(cf_start:cf_stop, 1:num_channels);
end
figure
plot(start_positions_cf)



