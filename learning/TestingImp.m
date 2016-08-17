classdef TestingImp < handle
% encapulates mechanism for testing
    properties
        learningAdpt
    end

    methods(Access = private)
        function training_sets = get_training_sets(obj, k) % leave one out training
            training_sets = [1: k-1, k + 1: obj.learningAdpt.get_num_loaded_sets()];
        end
    end

    methods
        function init(obj, learningAdpt)
            obj.learningAdpt = learningAdpt;
        end

        function start_evaluation(obj)
            predicted_labels = [];
            predicted_scores = [];
            n = obj.learningAdpt.get_num_loaded_sets();
            for test_ind = 1: n
                obj.learningAdpt.train(obj.get_training_sets(test_ind));
                [cur_label, cur_score] = obj.learningAdpt.infer(test_ind);
                predicted_scores = [predicted_scores ; cur_score];
                predicted_labels = [predicted_labels; cur_label];
            end

            obj.learningAdpt.evaluate_result(predicted_labels, predicted_scores, 1:n);

        end
        
    end
end