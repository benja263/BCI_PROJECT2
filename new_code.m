% enter the sequence of tasks: --------------------------------------------

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
tasks = [1; 3; 5; 2; 3; 6];

% check that the tasks entered are OK
if ( ( max(tasks) > 8 ) || (min(tasks) < 1 ) )
    error('The tasks entered are not known.')
end

% frequencies of interest for PSD
freq = [8, 9, 10, 11, 12];

% window size for moving average
window_size = 5;
% -------------------------------------------------------------------------

addpath(genpath('./biosig')) %adds folder recursively
addpath(genpath('./eeglab_current')) %adds folder recursively

filenames = ['anonymous.20170613.161402.offline.mi.mi_bhbf.gdf';...
    'anonymous.20170613.162331.offline.mi.mi_bhbf.gdf'; ...
    'anonymous.20170613.162934.offline.mi.mi_bhbf.gdf'];

% get the data ready
[s, h, sample_rate] = get_data(filenames);

% separate the data of each event
[s1, h1, s786, h786, s781, h781, s_left, h_left, s_right, h_right] = ...
    event_separation(s, h);

% do the tasks on new data
new_s_left = s_left;
new_s_right = s_right;
[new_s_left, new_s_right] = do_tasks(tasks, new_s_left, new_s_right, sample_rate, freq, window_size);

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

function [s1, h1, s786, h786, s781, h781, s_left, h_left, s_right, h_right] ...
    = event_separation(s, h)

    % create a vector with the event numbers:
    % 1:
    % 786:
    % 781:
    % 771: left/ both feet
    % 773: right/ both hands
    event_nb = [1, 786, 781, 771, 773];
    
    [s1, h1]           = get_event(s, h, event_nb(1));
    [s786, h786]       = get_event(s, h, event_nb(2));
    [s781, h781]       = get_event(s, h, event_nb(3));
    [s_left, h_left]   = get_event(s, h, event_nb(4));
    [s_right, h_right] = get_event(s, h, event_nb(5));

end

function [s_separated, h_separated] = get_event(s, h, event_nb)

    % get the infos in h of hte wanted event
    h_separated = h(h(:, 1)==event_nb, :);
    
    % get the positions of the wanted event
    start_pos = h_separated(:, 2);
    stop_pos = start_pos + h_separated(:, 3) - 1;
    
    % get the wanted data
    s_separated = s(start_pos : stop_pos, :);
    
end

function [new_s_left, new_s_right, pxx, f] = do_tasks(tasks, s_left, s_right, sample_rate, freq, window_size)

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

            % topoplot
            figure
            topoplot(s_tasks(2,:),chanlocs16);
        end

        % laplacian spatial filtering
        if ( tasks(i) == 4 )
            s_tasks = laplacian(s_tasks, lap);
            
            %topoplot
            figure
            topoplot(s_tasks(2,:),chanlocs16);
        end

        % mu frequency filtering
        if ( tasks(i) == 5 )
            s_tasks = mu(s_tasks, sample_rate);
            
            figure
            plot(s_tasks(:, 8:12))
            title('mu filter')
            legend('channel 8', 'channel 9', 'channel 10', 'channel 11', 'channel 12')    
        end

        % beta frequency filtering
        if ( tasks(i) == 6 )
            s_tasks = beta(s_tasks, sample_rate);
            
            figure
            plot(s_tasks(:, 8:12))
            title('beta filter')
            legend('channel 8', 'channel 9', 'channel 10', 'channel 11', 'channel 12')            
        end

        % get PSD
        if ( tasks(i) == 7 )
            [pxx, f] = get_psd(s_tasks, freq);
            
            figure
            plot(f, pxx)
            title('PSD')
            legend('channel 8', 'channel 9', 'channel 10', 'channel 11', 'channel 12')
        end

        % get moving average
        if ( tasks(i) == 8 )
            s_tasks = moving_average(s_tasks, window_size);
            
            figure
            plot(s_tasks(:, 8:12))
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

function [pxx, f] = get_psd(s, freq)
    [pxx, f] = pwelch(s(:, 8:12), 256, 256/2, freq, 512); 
end

function s_movavg = moving_average(s, window_size)
    b = 1/window_size * ones(1, window_size);
    a = 2;
    s_movavg = filter(b, a, s);
end