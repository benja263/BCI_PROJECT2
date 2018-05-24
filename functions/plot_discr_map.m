function [] = plot_discr_map(train_data, train_labels, model, show_histograms)
%PLOT_DISCR_MAP Summary of this function goes here
%   Detailed explanation goes here
w = model.Sigma \ (model.Mu(1,:) - model.Mu(2,:))';
tr_data_trans = train_data * w;
idx = min(tr_data_trans) - std(tr_data_trans):0.05:max(tr_data_trans) + std(tr_data_trans);
norm_dist_771 = fitdist(tr_data_trans(train_labels==771), 'Normal');
y_771 = pdf(norm_dist_771, idx);
norm_dist_773 = fitdist(tr_data_trans(train_labels==773), 'Normal');
y_773 = pdf(norm_dist_773, idx);
figure;
plot(idx, y_771 * 1000, 'LineWidth',2, 'Color', 'blue');
hold on;
plot(idx, y_773 * 1000, 'LineWidth',2, 'Color', 'red');
if isequal(show_histograms, 1)
    histogram(tr_data_trans(train_labels == 771), 50, 'FaceAlpha', 0.1, 'FaceColor', 'blue');
end
if isequal(show_histograms, 1)
    histogram(tr_data_trans(train_labels == 773), 50, 'FaceAlpha', 0.1, 'FaceColor', 'red');
end
hold off;
legend('both feet', 'both hands');
end

