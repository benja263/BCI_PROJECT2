% we need to extract the data 
addpath(genpath('./functions')) %adds folder recursively
kriton_files = dir('kriton/online');
load kriton_classifier.mat
load laplacian_16_10-20_mi.mat
kriton_files([kriton_files.isdir]) = [];
file_name = extractfield(kriton_files,'name');
[s, h, sample_rate] = get_data(strcat('./kriton/online/',file_name{end}));
% extracting hands
test_s = s(h(7,2):(h(7,2)+h(7,3)-1),:);
window = 512;
window_s = test_s(100:612-1,:);
tic
[Label,pp,cost] = onlineDecoder(window_s,1,Model,freq_ind,channels);
toc


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
    
    w_start_pos = floor(start_pos/shift) + 1;
    w_stop_pos = floor(stop_pos/shift) + 1;
    
    for i=1:length(w_start_pos)
        labels(w_start_pos(i):w_stop_pos(i)) = event_nb(1);
    end
       
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

function s_car = car(s)

    % get the mean of the data
    s_mean = mean(s, 2);
    
    % subtract the mean from the signal of each electrode
    s_car = s - repmat(s_mean, 1, size(s, 2));
    
end