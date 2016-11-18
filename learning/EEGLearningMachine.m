classdef EEGLearningMachine < EEGLearningMachineInterface
% I am going to break EEG learning into 3 parts cooperating with each other
% this is the training machine which is doing the heavy lifting, Data, Machine, Controller Framework
% note that it will require data from EEGStudySetInterface (rolling fashion)
% k-fold cross_validated training is now implemented in this class


    properties
        normalization_machine = MaxMinNormalization();
        pca_machine = PCAMachine();
        k_means_machine = KMeansMachine();
        sup_learner;
        studyset;
        toVisualize = true;
    end

    methods 

        function set_studyset(obj, studyset)
            obj.studyset = studyset;
        end

        function reset(obj) % reset the normalization parameters 
            [X, label] = obj.studyset.get_all_data();
            fprintf('reseting EEGLearning Machine with (pos: %d,neg: %d)',sum(label), sum(abs(1 - label)))

            % start normlization machine
            obj.normalization_machine.init(obj.pca_machine, obj.k_means_machine);
            obj.normalization_machine.reset(X);
        end

        function set_suplearner(obj, suplearner)
            obj.sup_learner = suplearner;
        end


        %% data prepossessing: like normalization e.t.c Of course I could/ might delegate it to specialized prepossessing machine
        function [x_normalized] = normalize(obj, X) % stores normalization parameters inside the dedicated normalization machine
            x_normalized = obj.normalization_machine.normalize(X);
        end
        
        %% training: delegate it to different 
        function cv_training(obj) % train a superviseed_learner
            all_loss = [];

            obj.studyset.new_training_cycle();
            fold_count = 0;
            while true
                 fold_count = fold_count + 1;
                [isEnd, training_data, training_label, cv_data, cv_label] = obj.studyset.get_next_fold_of_training_and_cv_data();
                if isEnd
                    break
                else
                    fold_loss = [];
                    % normalize data
                    norm_training_data = obj.normalize(training_data);
                    norm_cv_data = obj.normalize(cv_data);
                    % train for all parameters

                    
                    obj.sup_learner.get_num_tuning_param()
                    for idx = 1: obj.sup_learner.get_num_tuning_param()
                        obj.sup_learner.set_tuning_param(idx);
                        obj.sup_learner.train(norm_training_data, training_label, obj);
                        cur_loss = obj.sup_learner.loss(norm_cv_data, cv_label);

                        fold_loss = [fold_loss, cur_loss]; % EXPANDING LIST
                        obj.visualize(cv_data, cv_label, sprintf('visualize with tuning param_set (%d) cv_set (%d)', idx, fold_count));
                    end
                    all_loss = [all_loss; fold_loss]; %EXPANDING MATRIX
                end
            end
            fprintf('this are all loss from current cvtraining\n')
            disp(all_loss)

            % select the least loss
            mean_loss = mean(all_loss, 1);
            disp(mean_loss)
            [val, idx] = min(mean_loss);
            % retrain the suplearner
            param = obj.sup_learner.set_tuning_param(idx);
            fprintf('the best loss is %s with param (%s)', val, param);
            [all_train_data, all_train_label] = obj.studyset.get_all_training_data();
            norm_all_train_data = obj.normalization_machine.normalize(all_train_data);
            obj.sup_learner.train(norm_all_train_data, all_train_label, obj);

        end

        function train(obj)
            param = obj.sup_learner.set_tuning_param(1);
            fprintf('training with 1st tunning parameter defined in studyset');
            [all_train_data, all_train_label] = obj.studyset.get_all_training_data();
            norm_all_train_data = obj.normalization_machine.normalize(all_train_data);
            obj.sup_learner.train(norm_all_train_data, all_train_label, obj);
        end

        %% prediction: returns margin, score, e.t.c to original data
        function [label, score] = predict(obj, X) 
            norm_data = obj.normalization_machine.normalize(X);
            [label, score] = obj.sup_learner.infer(norm_data);
        end

        %% basic data visualization, say histogram of confidence 

        function visualize(obj, X, true_label, graph_title) % delegated to the sup_leaenre to visualize data
            if obj.toVisualize
                [pred_label, score] = obj.predict(X);
                obj.histogram_visualize(score, true_label, graph_title);
                obj.pca_visualize(X, true_label, pred_label, graph_title);
            end
        end

        function histogram_visualize(obj, score, true_label, graph_title)
            pos_score = score(true_label == 1);
            neg_score = score(true_label == 0);
            figure
            histogram(pos_score);
            hold on
            histogram(neg_score);
            hold off
            title(graph_title);
        end

        function pca_visualize(obj, X, true_label, pred, graph_title)
            figure;
            subplot(121)
            obj.pca_machine.scatter2(X, true_label);
            title('target label')
            subplot(122)
            obj.pca_machine.scatter2(X, pred);
            title(graph_title);
        end

        % TODO implement temporal evolution

    end
end