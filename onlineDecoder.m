function [pp] = onlineDecoder(EEG,type)
    addpath(genpath('./biosig')) %adds folder recursively
    addpath(genpath('./eeglab_current')) %adds folder recursively
    if type == 1 % car
        EEG = car(EEG);
    else % lap
        % get the laplacian matrix
        load('laplacian_16_10-20_mi.mat');
        EEG = laplacian(EEG, lap);
    end
    % perfrom psd
    sample_rate = 512;
    freq = 4:2:48;
    shift = sample_rate * (0.0625);
    chunksize = sample_rate;
    s_w = zeros(floor((size(EEG, 1) / shift)), sample_rate, 16);
    for c = 1 : size(EEG, 2)
        cur_channel = EEG(:, c);
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

