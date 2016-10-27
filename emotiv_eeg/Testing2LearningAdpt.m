classdef Testing2LearningAdpt < handle
% implements methods for evaluation 
    properties
        eeglearning
    end

    methods
        function init(obj, eeglearning)
            obj.eeglearning = eeglearning;
        end

        function n = get_num_loaded_sets(obj)
            n = length(obj.eeglearning.EEGStudys);
        end

        % infer for set K
        function [label, score] = infer(obj, testing_set)
            [label, score] = obj.eeglearning.testing_adpt_infer(testing_set);
        end

        function train(obj, training_sets)
            obj.eeglearning.clean_train(training_sets);
        end

        function evaluate_result(obj, labels, scores, testing_set)
            obj.eeglearning.testing_adpt_eval(labels, scores, testing_set);
        end


    end

end