function [out_data,out_labels] = CleanData(data, in_labels)
% cleans the data to keep only 2 class system (hands,feet)
% shuffling

    labels_771 = find(in_labels == 771);
    labels_773 = find(in_labels == 773);
    data_771 = data(labels_771,:);
    data_773 = data(labels_773,:);
    out_labels = [labels_771;labels_773];
    out_data = [data_771; data_773];
    shuffle_ind = randperm(length(out_labels));
    out_labels = in_labels(out_labels);
    out_labels = out_labels(shuffle_ind);
    out_data = out_data(shuffle_ind,:);
end

