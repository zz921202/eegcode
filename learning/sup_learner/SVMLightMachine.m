classdef SVMLightMachine < SupervisedLearnerInterface

    % searching parameter adjustment will need to be performed manually
    properties
        params = '-c 1 -t 2 -g 0.1 '; % trade-off large c for overfitting
                                 % RBF kernal function 
                                 %  - parameter gamma in rbf kernel exp(-gamma ||a-b||^2)
        data_file_name = 'temp_data_dump';
        output_file_name = 'temp_data_out';
        model_file_name = '';
        label_mapping = []; % the first one is -1 and second is 1
        pca = PCAMachine();
        col_mean;
        col_diff;
        tuning_param_array = 3.^(-1)

    end

    methods(Access = private)
        function training_labels = get_training_label(obj, y, modify)
            % modify indicates whether to change to underlying training label mapping
            if nargin > 2
                obj.label_mapping = unique(y);
            end
            assert(length(obj.label_mapping) < 3, 'number of labels > 3 ');
            training_labels = double(-(y == obj.label_mapping(1)) + (y == obj.label_mapping(2)));
        end

        function actual_labels = get_actual_label(obj, y)
            actual_labels = (y == -1) .* obj.label_mapping(1) + (y == 1) .* obj.label_mapping(2);
        end

        function prob = get_prob(obj, y)
            % I used sigmoid function to convert margin to probability
            prob = 1 ./ (1 + exp(-y));
        end

         function matrix = column_transform(obj, matrix) % normalization for better fitting and visualization
            for col = 1 : size(matrix, 2)

                curcol = matrix(:, col);
                % figure;
                % hist(curcol(:))
                % title('before transformation')
                if obj.col_diff == 0
                    curcol = curcol - obj.col_mean(col);
                else
                    curcol  = (curcol - obj.col_mean(col)) / obj.col_diff(col);
                end
                matrix(:, col) = curcol;
                % figure;
                % hist(curcol(:))
                % title('after transform')
            end
        end

        function col_tranform_param(obj, matrix)
            obj.col_mean = mean(matrix);
            obj.col_diff = max(matrix) - min(matrix);
        end

        function set_param_linear(obj, trade_off)
            obj.params = sprintf('-c %s -t 0 ', num2str(trade_off));
        end

        function set_param_rbf(obj, trade_off)
            obj.params = sprintf('-c %s -t 2 -g 5 ', num2str(trade_off));
        end


    end
    methods

        % used as a demo to get an idea of basic performance
        % I will generate a different file for each training iteration
        % parameter sweeping requires a 2D structure, which will be explored subsequently TODO
        function train(obj, X, y, param_tuple)
            % obj.pca.CUTOFF = 95
            % obj.pca.fit(X, '');
            % X = obj.pca.infer(X);

            % obj.col_tranform_param(X);
            % X = obj.column_transform(X);
            
            data_set = [ obj.get_training_label(y, 1), X];
            [~, obj.model_file_name] = unix('date +/_svm_%F_-%H:%M_%S%N');

            obj.model_file_name = strtrim(obj.model_file_name(2:length(obj.model_file_name)));
            tic
            disp('start')
            svmlight_train(data_set, obj.params, obj.data_file_name, obj.model_file_name);
            disp('finish')
            toc
        end

        % infer label for new data
        function [labels, scores] = infer(obj, Xnew)
%             Xnew = obj.pca.infer(Xnew);
%             Xnew = obj.column_transform(Xnew);
            data_set = [zeros(size(Xnew,1) , 1), Xnew];
            size(Xnew,1)
            tic
            disp('start evaluation')
            margin = svmlight_infer(data_set, obj.model_file_name, obj.output_file_name);
            disp('finish')
            toc
            predicted_labels = -(margin < 0) + (margin >= 0);
            labels = obj.get_actual_label(predicted_labels);
            scores = margin;
        end

        function curloss = loss(obj, Xtest, ytest)
%             Xtest = obj.pca.infer(Xtest);
%             Xtest = obj.column_transform(Xtest);
            data_set = [zeros(size(Xtest,1) , 1), Xtest];
            margin = svmlight_infer(data_set, obj.model_file_name, obj.output_file_name);

            actual_labels = obj.get_training_label(ytest);
            curloss = sum((actual_labels == -1) .* max((margin - 1), 0)) + sum((actual_labels == 1) .* max((1 - margin ), 0));
            fprintf('curloss is %s', num2str(curloss));
        end

        function svmm = clone(obj)
            svmm = SVMLightMachine();
            svmm.model_file_name = obj.model_file_name;
            svmm.label_mapping = obj.label_mapping;
            svmm.col_diff = obj.col_diff;
            svmm.col_mean = obj.col_mean;
        end

        function num = get_num_tuning_param(obj)
            num = length(obj.tuning_param_array);
        end

        function param = set_tuning_param(obj, idx)
            param = obj.tuning_param_array(idx);
            obj.set_param_rbf(param);
        end



    end
end