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
        data_path = ''
        window_gen = '' % name of window used 
    end

    methods 



    function init(obj)
        obj.section.set_window_param(obj.slide, obj.window_len)
        obj.study_set.init(obj.data_path, obj.section)
        
    end

    %% logging 

    %% test_implementation, the twin brother of logging etc

    %% evaluation criteria 


    end
end