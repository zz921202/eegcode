classdef KaggleController < handle
% I am going to break EEG learning into 3 parts cooperating with each other
% this is the container, i.e data part like model 
% Data, Machine, Controller Framework
% setting parameters for investigation should be carried out here


    properties
        slide = 20
        window_len = 20
        section = KaggleSection()
        study_set = KaggleStudySet()
        learningMachine = EEGLearningMachine()
        window_gen = '' % name of window used 
        testimp = KaggleTestImp();
    end

    methods 



    function import(obj, data_path, save_data_path)
        obj.study_set.import_data(data_path);
        obj.section.set_window_param(obj.slide, obj.window_len);
        obj.study_set.set_section_prototype(obj.section);
        obj.study_set.save_data(save_data_path);
    end

    function load(obj, data_dir_path)
        obj.study_set.load_data(data_dir_path);
        svm_learner = SVMLightMachine();
        sampling_learner = SamplingMachine();
        sampling_learner.init(svm_learner);
        obj.learningMachine.set_studyset(obj.study_set);
        obj.learningMachine.set_suplearner(sampling_learner);
        obj.learningMachine.reset();
        obj.study_set.set_learner(obj.learningMachine);
        obj.testimp.set_studyset(obj.study_set);
        obj.testimp.reset();
    end

    function start_testing(obj)
        obj.testimp.test();
    end




    end
end