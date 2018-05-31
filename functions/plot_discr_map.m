function [] = plot_discr_map(train_data, train_labels, model, show_histograms)
%PLOT_DISCR_MAP Summary of this function goes here
%   Detailed explanation goes here
sigma_sum_classes = sum(model.Sigma, 3);
if size(sigma_sum_classes, 1) == 1
    sigma_sum_classes = diag(sigma_sum_classes);
end
w = sigma_sum_classes \ (model.Mu(1,:) - model.Mu(2,:))';
tr_data_trans = train_data * w;
idx = (min(tr_data_trans) - 2 * std(tr_data_trans)):0.05:(max(tr_data_trans) + 2* std(tr_data_trans));
norm_dist_771 = fitdist(tr_data_trans(train_labels==771), 'Normal');
y_771 = pdf(norm_dist_771, idx);
norm_dist_773 = fitdist(tr_data_trans(train_labels==773), 'Normal');
y_773 = pdf(norm_dist_773, idx);
fig = figure;
set(fig,'defaultAxesColorOrder',[[0, 0, 0]; [0, 0, 0]]);
plot(idx, y_771, 'LineWidth',2, 'Color', 'blue');
hold on;
plot(idx, y_773, 'LineWidth',2, 'Color', 'red');
ylabel('p(x)')
if isequal(show_histograms, 1)
    yyaxis right
    histogram(tr_data_trans(train_labels == 771), 50, 'FaceAlpha', 0.1, 'FaceColor', 'blue');
end
if isequal(show_histograms, 1)
    histogram(tr_data_trans(train_labels == 773), 50, 'FaceAlpha', 0.1, 'FaceColor', 'red');
    ylabel('window count')
end
% histfit(tr_data_trans(train_labels == 771))
% histfit(tr_data_trans(train_labels == 773))
hold off;
xlabel('PSD projected on most discriminant dimension')
legend({'both feet', 'both hands'}, 'Location', 'northwest');
set(findall(gcf,'-property','FontSize'),'FontSize',16)
end

