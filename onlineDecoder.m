function [curr_decision, pp] = onlineDecoder(EEG,prev_decision,support)
    type = support.type;
    classifier = support.model;
    freq = 4:2:48;
    [~, freq_ind, ~] = intersect(freq,support.frequencies);
    channels = support.channels;
    if type == 1 % car
        EEG = car(EEG);
    else % lap
        EEG = EEG*support.lap;
    end
    
    % perfrom psd
    sample_rate = 512;
    psd = get_psd(EEG, freq, sample_rate);
    data = [];
    for i = 1:length(freq_ind)
        data = [data, psd(:,freq_ind(i),channels(i))];
    end
    %toc
    [Label,pp,~] = predict(classifier,data);  
    curr_decision = [length(find(Label == 773))/length(Label),...
        length(find(Label == 771))/length(Label) ];
end

function s_car = car(s)

    % get the mean of the data
    s_mean = mean(s, 2);
    
    % subtract the mean from the signal of each electrode
    s_car = s - repmat(s_mean, 1, size(s, 2));
    
end

function pxx = get_psd(s, freq, sample_rate)
    shift = sample_rate * (0.0625);
    chunksize = sample_rate;
    
    s_w = zeros(floor((size(s, 1) / shift)), sample_rate, 16);
    for c = 1 : size(s, 2)
        cur_channel = s(:, c);
         windows_cur_channel = buffer(cur_channel,chunksize,...
             chunksize-shift)';
        s_w(:, :, c) = windows_cur_channel;
    end
    
    pxx = zeros(size(s_w, 1), length(freq), length(1:16));
    for w = 1 : size(s_w, 1)
        pxx(w, :, :) = pwelch(squeeze(s_w(w, :, :)),...
            256, 256/2, freq, sample_rate); 
    end 
end
