function psd = calculateClassifierFisher(data,type)
    psd =  data{2,type};
    events = data{2,3};
    psd_left_std=squeeze(std(psd(events ==771, :, :)));
    psd_left_mean = squeeze(mean(psd(events ==771, :, :)));
    psd_right_std = squeeze(std(psd(events ==773, :, :)));
    psd_right_mean = squeeze(mean(psd(events ==773, :, :)));
    psd = (abs(psd_left_mean-psd_right_mean))...
        ./(sqrt(psd_left_std.^2+psd_right_std.^2));
    psd = psd.^2;
end
