classdef TestingImplementationInterface < handle
% This class will be attached to study set to drive the choice of sets used for testing 
% also drive the process of testing by calling train method in study set, basically the whole 


    properties

    end

    methods (Abstract)
        set_studyset(obj, studyset)

        reset(obj) % get information from studyset to set up testing schedule, after window extraction

        test(obj) % instruct studyset to carry out testing after eeglearning has been set up


        evaluate(obj, true_label, score, predicted_label) % plotting performed here



    end
end