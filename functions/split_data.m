function [tr_data, te_data] = split_data(data)
    tr_data = {'Car PSD Data','Lap PSD Data','Events'}; % traning data
    te_data = {'Car PSD Data','Lap PSD Data','Events'}; % test data
    tr_ind = zeros(size(data,1));
    te_ind = zeros(size(data,1));
    for i = 2:size(data,1)
       if strcmp(data{i,4},'offline')
           tr_ind(i) = i;
       else
           te_ind(i) = i;
       end
    end
    tr_ind = tr_ind(tr_ind ~= 0);
    te_ind = te_ind(te_ind ~= 0);
    car_data = [];
    lap_data = [];
    events = [];

    for i = 1:length(tr_ind)
       car_data =  [car_data; data{tr_ind(1),1}];
       lap_data =  [lap_data; data{tr_ind(1),2}];
       events = [events; data{tr_ind(1),3}];
    end
    tr_data{end+1,1} = car_data;
    tr_data{end,2} = lap_data;
    tr_data{end,3} = events;

    car_data = [];
    lap_data = [];
    events = [];

    for i = 1:length(te_ind)
       car_data =  [car_data; data{te_ind(1),1}];
       lap_data =  [lap_data; data{te_ind(1),2}];
       events = [events; data{te_ind(1),3}];

    end
    te_data{end+1,1} = car_data;
    te_data{end,2} = lap_data;
    te_data{end,3} = events;

end