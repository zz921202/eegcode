myeegcode_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(myeegcode_dir)
InitEEGLab.init()

% study_set = KaggleStudySet();
% gen_window = 'EEGWindowBandEnergy';
% prototype_section = KaggleSection();
% prototype_section.set_window_param(20, 20, gen_window);
% study_set.section_prototype = prototype_section;
% study_set.import_data('/Volumes/Samsung_T3/Intra_Data/my_test_data');
% study_set.save_data('/Volumes/Samsung_T3/Intra_Data/tmp/my_test_data');

controller = KaggleController()
controller.load('/Volumes/Samsung_T3/Intra_Data/tmp/my_test_data_1')
study_set = controller.study_set;

% controller.start_testing()