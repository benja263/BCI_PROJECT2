function [Label,pp,cost] = onlineDecoder(EEG,type,classifier,freq_ind,channels)

    if type == 1 % car
        EEG = car(EEG);
    else % lap
        % get the laplacian matrix
        load('laplacian_16_10-20_mi.mat');
        EEG = EEG*lap;
    end
    
    % perfrom psd
    sample_rate = 512;
    freq = 4:2:48;
    %tic
    psd = get_psd(EEG, freq, sample_rate);
    %toc
    data = [];
    %tic
    for i = 1:length(freq_ind)
        data = [data, psd(:,freq_ind(i),channels(i))];
    end
    %toc
    [Label,pp,cost] = predict(classifier,data);    
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
