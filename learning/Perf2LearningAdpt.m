classdef Perf2LearningAdpt < handle
    
    properties
        eegLearning
        algorithm_lag = 5;
        tag = 'LogisticRegression, ';
        step_size = 1;
        window_size = 2;
        log_file_name = 'eval_logging';

    end

    methods

        function init(obj, eegLearning)
            obj.eegLearning = eegLearning;
        end

        function [window_size, step_size, str] = get_window_step_size(obj)
            window_size = obj.window_size;
            step_size = obj.step_size;
            str = sprintf('window_size, %d, step_size, %d, ', window_size, step_size);
        end

        function num = get_algorithm_lag(obj)
            num = obj.algorithm_lag;
        end

        function str = get_tag(obj)
            str = obj.tag;
        end

        function str = get_logfile_name(obj)
            str = obj.log_file_name;
        end



    end
end