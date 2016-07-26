myeegcode_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(myeegcode_dir)
InitEEGLab.init()

% 


% matlabpool open
vidya = [myeegcode_dir, '/processed_data/Vidya_june_6_Data/'];
all_files = {
             '1610',
             '1611',
             '1626',
             '1630',
             '1636',
             '1637',
             '1639',
             '1645',
             };

compose_file = @(number) ['' number '_raw.set']
for idx  = 1 : length(all_files)
    filename = all_files{idx};
    dd = EEGStudyEmotiv();
    file_dir = [vidya, compose_file(filename)];
    disp(['...... importing', file_dir, '......']);
    dd.import_data(file_dir, filename);
    disp('....extracting features.....');
    dd.set_window_params(2, 1, 'EEGWindow3Hz');

    disp('..............')
    studies(idx) = dd;
end
cg = EEGLearning();
cg.set_study(studies);
cg.plot_temporal_evolution(1 : length(all_files));
cg.pca()
% matlabpool close