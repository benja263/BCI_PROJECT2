function [data] =  day_selector(psd_file,name,date)
% returns a psd_data cell for each individual according to the session
% needs to be provided with the psd_file, name and date in string format
% example: [emilydata] =  day_selector(psd_file,'emily','20180326')
data = {'Car PSD Data','Lap PSD Data','Events', name,date};

for i = 2:size(psd_file,1)
    names = strsplit(psd_file{i,2},'/');
    if length(names) > 1
        if strcmp(names{2},name)
           dates = strsplit(psd_file{i,1},'.');
           if strcmp(dates{2},date)
               data{end+1,1} = psd_file{i,3};
               data{end,2} = psd_file{i,4};
               data{end,3} = psd_file{i,5};
               data{end,4} = names{3};
               data{end,5} = dates{3};
           end
        end
    else
        dates = strsplit(psd_file{i,1},'.');
        if strcmp('anonymous',dates{i}) 
           data{end+1,1} = psd_file{i,3};
           data{end,2} = psd_file{i,4};
           data{end,3} = psd_file{i,5};
           data{end,4} = psd_file{i,6};
           data{end,5} = names{3};
           data{end,6} = dates{3};
        end  
    end
end
