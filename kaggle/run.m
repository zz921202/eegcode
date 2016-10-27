myeegcode_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(myeegcode_dir)
InitEEGLab.init()

study_set = KaggleStudySet();
gen_window = 'EEGWindowBandAmplitude';
prototype_section = KaggleSection();
prototype_section.set_window_param(20, 20, gen_window);
study_set.section_prototype = prototype_section;
study_set.import_data('/Volumes/Samsung_T3/Intra_Data/train_1');
study_set.save_data('/Volumes/Samsung_T3/Intra_Data/tmp/tain_1_band_amp');