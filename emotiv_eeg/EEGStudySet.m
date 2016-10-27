classdef EEGStudySetInterface < handle
% This class inherits the old EEGLearning's data part as a container of multiple data sets


    properties
    end

    methods 
        function [isEnd, training_data, training_label, cv_data, cv_label] = get_next_fold_of_training_and_cv_data(obj)
        end

        function isEnd = move_to_next_train_test_partition(obj)
        end

        xfunction load_data(obj, path_toData_dir)
        end

        function save_data(obj, path_toData_dir)
        end

        function init(obj, additional_input)
        end


    end
end