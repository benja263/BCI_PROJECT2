freq = 4:2:48;

addpath(genpath('./biosig')) %adds folder recursively
addpath(genpath('./eeglab_current')) %adds folder recursively
addpath(genpath('./functions')) 

load 'channel_location_16_10-20_mi.mat'

filenames = ['./emily/offline/aj9.20180326.153615.offline.mi.mi_bhbf.gdf';...
    './emily/offline/aj9.20180326.154532.offline.mi.mi_bhbf.gdf'; ...
    './emily/offline/aj9.20180326.155323.offline.mi.mi_bhbf.gdf'];

[s, h, sample_rate] = get_data(filenames);
lap_s = lapFiltering(s);
labels =  event_separation(s, h);
car_s = car(s);
left_raw = s(labels==771,:);
right_raw = s(labels==773,:);
baseline=s(labels==786,:);
left_car = car_s(labels==771,:);
right_car = car_s(labels==773,:);
left_lap = lap_s(labels==771,:);
right_lap = lap_s(labels==773,:);

figure
subplot(2,3,1)
test=(mean(left_raw)-mean(baseline))./(mean(baseline));
topoplot(test,chanlocs16,'maplimits','maxmin');%limitsCARMU);
colorbar
title('Feet raw')
subplot(2,3,2)
topoplot((mean(left_car)-mean(baseline))./mean(baseline),chanlocs16,'maplimits','maxmin');
colorbar
title('Feet CAR')
subplot(2,3,3)
topoplot(mean(left_lap),chanlocs16,'maplimits','maxmin');%limitsCARMU);
colorbar
title('Feet Lap')
subplot(2,3,4)
topoplot(mean(right_raw),chanlocs16,'maplimits','maxmin');
colorbar
title('Hands raw')
subplot(2,3,5)
topoplot(mean(right_car),chanlocs16,'maplimits','maxmin');%limitsCARMU);
colorbar
title('Hands CAR')
subplot(2,3,6)
topoplot(mean(right_lap),chanlocs16,'maplimits','maxmin');
colorbar
title('Hands Lap')

function [s, h, sample_rate] = get_data(filenames)

    % load the files and concatenate the data
    [s, h] = sload(filenames(1, :));
    sample_rate = h.SampleRate;
    h = [h.EVENT.TYP, h.EVENT.POS, h.EVENT.DUR]; 
    for i = 2 : size(filenames, 1)
        [s1, h1] = sload(filenames(i, :));
        h = [[h(:, 1); h1.EVENT.TYP], ...
            [h(:, 2); h1.EVENT.POS + size(s,1)], ...
            [h(:, 3); h1.EVENT.DUR]];
        s = [s; s1];
    end
    
    % erase the null line
    s = s(:, 1:16);
    
end

function pxx = get_psd(s, freq, sample_rate)
    shift = sample_rate * (0.0625);
    chunksize = sample_rate;
    
    s_w = zeros(floor((size(s, 1) / shift)), sample_rate, 16);
    for c = 1 : size(s, 2)
        cur_channel = s(:, c);
        %windows_cur_channel = cur_channel(bsxfun(@plus,(1:chunksize)...
         %   ,(0:shift:length(cur_channel)-chunksize)'));
         windows_cur_channel = buffer(cur_channel,chunksize,...
             chunksize-shift)';
        s_w(:, :, c) = windows_cur_channel;
    end
    
    pxx = zeros(size(s_w, 1), length(freq), length(1:16));
    for w = 1 : size(s_w, 1)
        pxx(w, :, :) = pwelch(squeeze(s_w(w, :, :)),...
            256, 256/2, freq, sample_rate); 
    end 
    w = shift * (0 : size(s, 1)/ shift) + 1;
    f = freq;
end

function labels = event_separation(psd, h)

    % create a vector with the event numbers:
    % 1: initialization
    % 786: fixation
    % 781: continuous feedback
    % 771: cue left/ both feet
    % 773: cue right/ both hands
    event_nb = [1, 786, 781, 771, 773];
    labels = zeros(size(psd,1),1);
    labels = get_event(h, [event_nb(4), event_nb(3)],labels);
    labels = get_event(h, [event_nb(5), event_nb(3)],labels);
    labels = get_event(h, event_nb(1),labels);
    labels = get_event( h, event_nb(2),labels);

end

function labels = get_event( h, event_nb,labels)
    shift = 32;
    
    % get the infos in h of hte wanted event
    idx = find(h(:, 1)==event_nb(1));
    if length(event_nb) == 2 && event_nb(2) == 781
       idx = idx+1;
    end
    h_separated = h(idx, :);
    
    % get the positions of the wanted event
    start_pos = h_separated(:, 2);
    stop_pos = start_pos + h_separated(:, 3) - 1;
    
    for i=1:length(start_pos)
        labels(start_pos(i):stop_pos(i)) = event_nb(1);
    end
       
end

function lap_s = lapFiltering(s)
    load laplacian_16_10-20_mi.mat;
    lap_s =  s*lap;
end

function s_car = car(s)

    % get the mean of the data
    s_mean = mean(s, 2);
    
    % subtract the mean from the signal of each electrode
    s_car = s - repmat(s_mean, 1, size(s, 2));
    
end