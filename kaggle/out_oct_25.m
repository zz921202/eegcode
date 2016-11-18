% for idx = 1: 20
%     figure
%     sec = study_set.pos_section_lis(idx);
%     sec.plot_temporal_evolution_image()
% end

disp('negative images')
for idx = 1: length(study_set.neg_section_lis)
%     figure
    sec = study_set.neg_section_lis(idx);
    sec.plot_temporal_evolution_image();
    title(sec.toString());
end
% close all