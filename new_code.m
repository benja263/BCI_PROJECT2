function [psd_file ,added] = new_code(filename,filepath,psd_file)% enter the sequence of tasks: --------------------------------------------

% The different tasks are:
% 1: take data from both feet (left)
% 2: take data from both hands (right)
% 3: car spatial filtering
% 4: laplacian spatial filtering
% 5: mu frequency filtering
% 6: beta frequency filtering
% 7: PSD
% 8: moving average
% example: tasks = [1; 3; 5; 2; 3; 6]
tasks = [1; 3; 7;];

% check that the tasks entered are OK
if ( ( max(tasks) > 8 ) || (min(tasks) < 1 ) )
    error('The tasks entered are not known.')
end

% frequencies of interest for PSD
freq = [4:2:48];

% window size for moving average
window_size = 5;
% -------------------------------------------------------------------------

addpath(genpath('./biosig')) %adds folder recursively
addpath(genpath('./eeglab_current')) %adds folder recursively

filenames = strcat(filepath,filename);
if  nargin == 3
    names = psd_file(:,1);
    name_exists = false;
    for name=1:length(names)
       if strcmp(filename,names{name})
            name_exists = true;
            added = false;
            return
       else
           added = true;
       end
    end
end
% get the data ready
[s, h, sample_rate] = get_data(filenames);



% do the tasks on new data
new_s_left = s;
new_s_right = s;
[psd_car,~] = do_tasks(tasks, new_s_left, new_s_right, sample_rate, freq, window_size);
tasks = [1;4;7];
[psd_lap,w_indexes] = do_tasks(tasks, new_s_left, new_s_right, sample_rate, freq, window_size);

% separate the data of each event
labels = ...
    event_separation(psd_car, h);

psd_name = 'psd_data.mat';
if  nargin == 3
    psd_file{end+1,1} = filename;
    psd_file{end,2} = filepath;
    psd_file{end,3} = psd_car;
    psd_file{end,4} = psd_lap;
    psd_file{end,5} = labels;
    psd_file{end,6} = w_indexes;
    save(psd_name,'psd_file')
else
    psd_file = cell(1,4);
    psd_file{1,1} = 'File Name';
    psd_file{1,2} = 'File Path';
    psd_file{1,3} = 'PSD_Data_Car';
    psd_file{1,4} = 'PSD_Data_Lap';
    psd_file{1,5} = 'Event Labels';
    psd_file{1,6} = 'Window Indexes';
    psd_file{2,1} = filename;
    psd_file{2,2} = filepath;
    psd_file{2,3} = psd_car;
    psd_file{2,4} = psd_lap;
    psd_file{2,5} = labels;
    psd_file{2,6} = w_indexes;
    save(psd_name,'psd_file')
end
end

% functions ---------------------------------------------------------------

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
       idx = sort(vertcat(idx, idx +1)); 
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

function [ pxx, w] = do_tasks(tasks, s_left, s_right, sample_rate, freq, window_size)

    % get the laplacian matrix
    load('laplacian_16_10-20_mi.mat');

    % get the channel locations
    load('channel_location_16_10-20_mi.mat');

    memory = 0;
    new_s_left = s_left;
    new_s_right = s_right;

    for i = 1 : length(tasks)

        % take the data from both feet (left)
        if ( tasks(i) == 1 )

            % save the previous task if there was one
            if ( memory ~= 0 )
                [new_s_left, new_s_right] = save_task(memory, s_tasks, new_s_left, new_s_right);
            end

            memory = 1;
            s_tasks = s_left;

        end
        if ( tasks(i) == 2 )

            % save the previous task if there was one
            if ( memory ~= 0 )
                [new_s_left, new_s_right] = save_task(memory, s_tasks, new_s_left, new_s_right);
            end
            
            memory = 2;
            s_tasks = s_right; 

        end

        % car spatial filtering
        if ( tasks(i) == 3 )
            s_tasks = car(s_tasks);


        end

        % laplacian spatial filtering
        if ( tasks(i) == 4 )
            s_tasks = laplacian(s_tasks, lap);

 
        end

        % mu frequency filtering
        if ( tasks(i) == 5 )
            s_tasks = mu(s_tasks, sample_rate);
              
        end

        % beta frequency filtering
        if ( tasks(i) == 6 )
            s_tasks = beta(s_tasks, sample_rate);
            
            
        end

        % get PSD
        if ( tasks(i) == 7 )
            [pxx, w, f] = get_psd(s_tasks, freq, sample_rate);

        end

        % get moving average
        if ( tasks(i) == 8 )
            s_tasks = moving_average(s_tasks, window_size);

        end
    end
    
    [new_s_left, new_s_right] = save_task(memory, s_tasks, new_s_left, new_s_right);

end

function s_car = car(s)

    % get the mean of the data
    s_mean = mean(s, 2);
    
    % subtract the mean from the signal of each electrode
    s_car = s - repmat(s_mean, 1, size(s, 2));
    
end

function s_lap = laplacian(s, lap)

    s_lap = s * lap;
    
end

function s_mu = mu(s, sample_rate)

    [b, a] = butter(4, [7.5, 12.5] * 2 / sample_rate);
    s_mu = filter(b, a, s);
    
end

function s_beta = beta(s, sample_rate)

    [b, a] = butter(2, [12.5, 30] * 2 / sample_rate);
    s_beta = filter(b, a, s);
    
end

function [new_s_left, new_s_right] = save_task(memory, s_tasks, s_left, s_right)
    if ( memory == 1 )
        new_s_left = s_tasks;
        new_s_right = s_right;
    else
        if ( memory == 2 )
            new_s_right = s_tasks;
            new_s_left = s_left;
        end
    end
end

function [pxx, w, f] = get_psd(s, freq, sample_rate)
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

function s_movavg = moving_average(s, window_size)
    b = 1/window_size * ones(1, window_size);
    a = 2;
    s_movavg = filter(b, a, s);
end