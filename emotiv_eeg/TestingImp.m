classdef TestingImp < handle
% encapulates mechanism for testing
    properties
        learningAdpt
        k = 2% kfold cross vali
        testing_sets = {};
        training_sets = {};
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
            obj.generate_test_sets();
            for test_ind = 1: length(obj.testing_sets)
                training_set = obj.training_sets{test_ind};
                testing_set = obj.testing_sets{test_ind};
                obj.learningAdpt.train(training_set);
                [cur_label, cur_score] = obj.learningAdpt.infer(testing_set);
                predicted_scores = [predicted_scores ; cur_score];
                predicted_labels = [predicted_labels; cur_label];
            end
            

            obj.learningAdpt.evaluate_result(predicted_labels, predicted_scores, 1:n);

        end

        function generate_test_sets(obj)
            obj.testing_sets = {};
            obj.training_sets = {};
            obj.leave_one_out_test();
        end

        function k_fold_split_test(obj)
            n = obj.learningAdpt.get_num_loaded_sets();
            for test_ind = 1: obj.k
                [training_set, testing_set] = obj.split_set(test_ind);
                obj.testing_sets{test_ind} = testing_set;
                obj.training_sets{test_ind} = training_set;
            end
        end


        function leave_one_out_test(obj)
            n = obj.learningAdpt.get_num_loaded_sets();
            for test_ind = 1: n
                training_set = obj.get_training_sets(test_ind);
                obj.testing_sets{test_ind} = test_ind;
                obj.training_sets{test_ind} = training_set; % change to training_set
            end
        end
    


    end
end