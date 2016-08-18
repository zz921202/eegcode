classdef TestingImp < handle
% encapulates mechanism for testing
    properties
        learningAdpt
        k = 2% kfold cross vali
    end

    methods
        function training_sets = get_training_sets(obj, k) % leave one out training
            training_sets = [1: k-1, k + 1: obj.learningAdpt.get_num_loaded_sets()];
        end
        function [training_set, testing_set] = split_set(obj, p)
            n = obj.learningAdpt.get_num_loaded_sets();
            chunk_size = floor(n / obj.k);
            training_set =[1:((p-1)*chunk_size), ((p)*chunk_size + 1):n];
            testing_set = ((p-1)*chunk_size + 1) : ((p)*chunk_size);
            if p == obj.k
                testing_set = ((p-1)*chunk_size + 1) : n;
            end
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
            
            for test_ind = 1: obj.k
                [training_set, testing_set] = obj.split_set(test_ind);
                obj.learningAdpt.train(training_set);
                [cur_label, cur_score] = obj.learningAdpt.infer(testing_set);
                predicted_scores = [predicted_scores ; cur_score];
                predicted_labels = [predicted_labels; cur_label];
            end
            

            obj.learningAdpt.evaluate_result(predicted_labels, predicted_scores, 1:n);

        end
        
    end
end