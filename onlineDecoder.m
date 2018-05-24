function [curr_decision, pp] = onlineDecoder(EEG,prev_decision,support)
    type = support.type;
    classifier = support.model;
    freq = 4:2:48;

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
    for i = 1:length(channels)
        [~, freq_ind, ~] = intersect(freq,support.frequencies(i));
        data = [data, psd(freq_ind,channels(i))];
    end
    %toc\
    a = 0.8;
    [~,pp,~] = predict(classifier,data);  
    [curr_decision] = integrate_posterior(pp,a,prev_decision);

end

function s_car = car(s)

    % get the mean of the data
    s_mean = mean(s, 2);
    
    % subtract the mean from the signal of each electrode
    s_car = s - repmat(s_mean, 1, size(s, 2));
    
end

function pxx = get_psd(s, freq, sample_rate)
    pxx = pwelch(s,...
            256, 256/2, freq, sample_rate); 
end


function [integrated_pp] = integrate_posterior(pp,a,prev_decision)
%This function integrates the posterior probabilities


        integrated_pp=zeros(1,2);
        integrated_pp(1)=a*prev_decision(1)+(1-a)*pp(1);
        integrated_pp(2)=a*prev_decision(2)+(1-a)*pp(2);

  


end


