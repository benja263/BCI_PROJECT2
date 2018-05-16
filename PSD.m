function [psd_file ,added] = PSD(filename,filepath,psd_file)
    filenames = strcat(filepath,filename);
    if  nargin == 3
        names = psd_file(:,1);
        for name=1:length(names)
           if strcmp(filename,names{name})
                added = false;
                return
           else
               added = true;
           end
        end
    end

    % get the data ready
    freq = 4:2:48;
    [s, h, sample_rate] = get_data(filenames);
    pxx = get_psd(s, freq, sample_rate);
    labels =  event_separation(pxx, h);
    psd_name = 'psd_data.mat';
    if  nargin == 3
        psd_file{end+1,1} = filename;
        psd_file{end,2} = filepath;
        psd_file{end,3} = pxx;
        psd_file{end,4} = labels;
        save(psd_name,'psd_file')
    else
        psd_file = cell(1,4);
        psd_file{1,1} = 'File Name';
        psd_file{1,2} = 'File Path';
        psd_file{1,3} = 'PSD Data';
        psd_file{1,4} = 'Event Labels';
        psd_file{2,1} = filename;
        psd_file{2,2} = filepath;
        psd_file{2,3} = pxx;
        psd_file{2,4} = labels;
        save(psd_name,'psd_file')
        added = true;
    end
end

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
    
    w_start_pos = floor(start_pos/shift) + 1;
    w_stop_pos = floor(stop_pos/shift) + 1;
    
    for i=1:length(w_start_pos)
        labels(w_start_pos(i):w_stop_pos(i)) = event_nb(1);
    end
       
end