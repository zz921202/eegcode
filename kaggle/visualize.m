pca_machine = study_set.learning_machine.pca_machine;
[feature, label, name_cell, endpoints_lis] = study_set.get_all_data();

pos_indicator = (label == 1);
neg_indicator = (label == 0);
figure
subplot(131)
pca_machine.scatter3(feature(pos_indicator, :), label(pos_indicator, :));
subplot(132)
pca_machine.scatter3(feature(neg_indicator, :), label(neg_indicator, :));
subplot(133)
pca_machine.scatter3(feature, label);

figure
subplot(131)
pca_machine.scatter2(feature(pos_indicator, :), label(pos_indicator, :));
subplot(132)
pca_machine.scatter2(feature(neg_indicator, :), label(neg_indicator, :));
subplot(133)
pca_machine.scatter2(feature, label);

%% temporal evolution coloring
pca_feature = pca_machine.infer(feature);
total_components_num = size(pca_feature, 2);
n = size(pca_feature, 1);
figure

for idx = 1 : total_components_num
    subplot(total_components_num, 1, idx)
    ax = gca;
    color_line(1:n, pca_feature(:,idx)', label)
    ax.XTick = endpoints_lis;
    ax.XTickLabel = name_cell;
end
%%
figure
for idx = 1 : total_components_num
    subplot(total_components_num, 1, idx)
    cur_feature = pca_feature(:,idx)';
    histogram(cur_feature(label == 1))
    hold on
    histogram(cur_feature(label == 0))
    hold off
end
%%
figure
colorscale = [min(min(pca_machine.principle_components)), max(max(pca_machine.principle_components))];
for idx = 1 : total_components_num
    subplot(total_components_num, 1, idx)
    reshape(pca_machine.principle_components(:, idx), 16, 6)
    imagesc(reshape(pca_machine.principle_components(:, idx), 16, 6), colorscale);
end

