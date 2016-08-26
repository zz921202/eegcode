classdef EEGLearning < handle
% this class handles more complicated machine learning tasks, combining multiple segments of 
% eeg recording, it allows the integration of pca projection with machine learning algorithms f
% for a more visual understanding of performance of of trained model

    properties
        EEGStudyInterfaces = [] % an array of EEGStudyIntrefaces, data extraction should have already been completed 
        
        p2;
        suplearner;
        debugging = false;
        EEGStudys = [];
        pca_machine = PCAMachine();
        k_means_machine = KMeansMachine();
        col_mean = [];
        col_diff = [];
        performanceEval = PerformanceEvalImp()
        evalAdpt;
    end

    methods(Access = private)

        %%%%%%%%%%%%%%%%%  helper functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % splitted struct is a sturct of vectors containing functional feature corresponding to each data source
        function splitted_struct = split_vector_back(obj, vec, datasets)
            [~, ~, endpoints] = obj.get_feature_and_label(datasets);

            end_point = 0;
            splitted_struct = {};
            for ind = 1:length(datasets)
                start_point = end_point + 1;
                end_point = endpoints(ind);
                splitted_struct{ind} = vec(start_point: end_point);
            end
        end

        function matrix = column_transform(obj, matrix) % normalization for better fitting and visualization
            for col = size(matrix, 2)
                curcol = matrix(:, col);
                if obj.col_diff == 0
                    curcol = curcol - obj.col_mean(col);
                else
                    curcol  = (curcol - obj.col_mean(col)) / obj.col_diff(col);
                end
                matrix(:, col) = curcol;
            end
        end

        function col_tranform_param(obj, matrix)
            obj.col_mean = mean(matrix);
            obj.col_diff = std(matrix);
        end

        function fit_pca(obj, datasets)
            [data_mat, color_types, endpoints, ~, color_codes] = obj.get_feature_and_label(datasets);
            obj.col_tranform_param(data_mat);
            obj.pca_machine.fit(obj.column_transform(data_mat), []);
        end


        function color_codes = change_to_chronological_coloring(obj, color_codes, endpoints)
            if unique(color_codes) == 0 % color according to the dataset in chronological order
                end_point = 0;
                % size(color_codes)
                for ind = 1:length(endpoints)
                    start_point = end_point + 1;
                    end_point = endpoints(ind);
                    color_codes(start_point: end_point) = ind;
                end
                % hist(color_codes);
            end
        end

        % use to transform color encoding to binary for classification, eg for SVM the label must be +1 and -1 
        function labels = color_transform(obj, color_types)
            labels = - ones(size(color_types));
            for encoding = active_set
                labels(color_types == encoding) = 1;
            end
        end

        % evaluate the result of supervised learner
        function evaluate_result(obj, X, y, pred, testing_set)

            figure
            conf = confusionmat(y, pred)
            imagesc(conf)
            xlabel('true label')
            ylabel('predicted label')

            figure
            subplot(121)
            obj.plot_temporal_evolution(testing_set, y);
            title('target_label label')
            subplot(122)            
            obj.plot_temporal_evolution(testing_set, pred);
            title('predicted label')
            % visualization of scatter

            % TODO
            figure;
            subplot(121)
            obj.pca_machine.scatter2(X, y);
            title('target label')
            subplot(122)
            obj.pca_machine.scatter2(X, pred);
            

        end

        function evaluate_score_result(obj, X, y, score, testing_set)
            figure
            subplot(121)
            obj.plot_temporal_evolution(testing_set, y);
            title('targets')
            subplot(122)            
            obj.plot_temporal_evolution(testing_set, score);
            title('prediction confidence score');
            % visualization of scatter
        end


        function [X, color_types, endpoints, data_windows, color_codes] = get_feature_and_label(obj, datasets, type_to_use) % opt1 selects which study to use
            % endpoints is used to separate the data windows to their corresponding EEGStudy instance so that we could 
            % delegate plot temporal evolution back to the original class
            % X each row represents an data point

            % type_to_use to extract a subset of data according to color designation
            if obj.debugging
                [X, color_types] = obj.generate_test_data();
                endpoints = [];
                return 
            end

            % load EEG study datasets
            if nargin < 2
                datasets = 1: length(obj.EEGStudys);
            end
            endpoints = zeros(1, length(datasets));
            cum_windows_counter = 0;
            X = [];
            color_types = [];
            data_windows = [];
            color_codes = [];
            for ind = 1: length(datasets)
                data_ind = datasets(ind);
                curEEGStudy = obj.EEGStudys(data_ind);

                [cur_feature_matrix, cur_color_types, cur_color_codes, cur_data_windows] = curEEGStudy.get_feature_matrix();
                % curEEGStudy.check_color();

                % data_windows = [data_windows, cur_data_windows];

                X = [X; cur_feature_matrix];
                color_types = [color_types; cur_color_types];
                color_codes = [color_codes; cur_color_codes];

                cum_windows_counter = cum_windows_counter + length(cur_color_codes);

                endpoints(ind) = cum_windows_counter;

                

            end
            color_codes = obj.change_to_chronological_coloring(color_codes, endpoints);

            if  nargin > 2

                indicator = zeros(size(color_types));
                for curtype = type_to_use
                    indicator = indicator + (color_types == curtype);
                end
                indicator = logical(indicator);
                X = X(indicator, :);
                % data_windows = data_windows(indicator);
                color_types = color_types(indicator);
                color_codes = color_codes(indicator);
            end
%             size(X)

            if ~isempty(obj.col_mean)
                X = obj.column_transform(X);
            end

            
        end

        function transdata = data_transform(obj, data_mat)
            transdata = obj.pca_machine.infer(data_mat);
        end

    end




    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods(Access = public)
        
        function set_study(obj, EEGStudys)
            % TODO: historical  code 
            % EEGStudys should have already imported data and generated data windows
            % get and plot pca coordinates immedaitely after loading
            warning('historical code, to be deprecated, call init instead');
            obj.EEGStudys = EEGStudys;
            obj.fit_pca(1:length(EEGStudys));
        end
        
        function init(obj, EEGStudys)
            obj.EEGStudys = EEGStudys;
            obj.fit_pca(1:length(EEGStudys));
            obj.evalAdpt = Perf2LearningAdpt();
            obj.evalAdpt.init(obj);
            obj.performanceEval.init(obj.evalAdpt);
            warning('set logging parameters')
        end

        function set_logging_params(obj, algorithm_lag, tag, window_size, step_size, log_file_name)
            logAdpt = obj.evalAdpt;
            logAdpt.tag = tag;
            logAdpt.algorithm_lag = algorithm_lag;
            logAdpt.step_size = step_size; 
            logAdpt.window_size = window_size;
            logAdpt.log_file_name = log_file_name;

        end


        function pca(obj, datasets)
            
            if nargin < 2
                [data_mat, color_types, endpoints, ~, color_codes] = obj.get_feature_and_label();
                datasets = 1:length(obj.EEGStudys);
            else
                [data_mat, color_types, endpoints, ~, color_codes] = obj.get_feature_and_label(datasets);

            end

            figure
            obj.pca_machine.scatter3(data_mat, color_codes);

            figure
            obj.pca_machine.scatter2(data_mat, color_codes);

            figure
            pca_coordinates = obj.pca_machine.infer(data_mat);
            subplot(311)
            title('pca 1 evolution');
            obj.plot_temporal_evolution(datasets, real(pca_coordinates(:,1)'))
            subplot(312)
            title('pca 2 evolution');
            obj.plot_temporal_evolution(datasets, real(pca_coordinates(:,2)'))
            subplot(313)
            title('pca 3 evolution');
            obj.plot_temporal_evolution(datasets,  real(pca_coordinates(:,3)'))
        end


        
        function plot_temporal_evolution(obj, datasets, feature_vec)
            % opt1 used to indicate to use external functionals to plot
            
            if nargin < 3
                vec = [];
                for idx = datasets
                    curStudy = obj.EEGStudys(idx);
                    y = curStudy.plot_temporal_evolution();
                   
                    vec = [vec, y(:)'];
                end
            else
                vec = feature_vec;
                % plited_vec = obj.split_vector_back(vec, datasets);
%                 for idx = datasets
%                     curStudy = obj.EEGStudys(idx);
%                     curStudy.toString
%                     curvec = splited_vec{1:length(datasets)};
%                     curStudy.plot_temporal_evolution(curvec);
%                 end         
            end
            [data_mat, color_types, endpoints, ~, color_codes] = obj.get_feature_and_label(datasets);
            
            color_line(1:length(vec),vec, color_codes');
            for endpoint = endpoints
                line([endpoint, endpoint], ylim, 'color', 'blue');
            end
            title('total temporal evolution')
            
        end

        function set_sup_learner(obj, suplearner)
            obj.suplearner = suplearner;
        end

        function sup_learning(obj, training_set)
            % learner must confrom to the SupervisedLearnerInterface

            [Xtrain, ytrain] = obj.get_feature_and_label(training_set);    
            % ytrain = obj.color_transform(ytrain);
            % obj.suplearner = feval(learner);
            obj.suplearner.train(Xtrain, ytrain); % of course we could change it to train bunch of models using
            [label, score] = obj.suplearner.infer(Xtrain); 
            % temporal visualization 
            obj.evaluate_result(Xtrain, ytrain, label, training_set)

        end

        
        function test_sup_learner(obj, testing_set)
            [Xtest, ytest] = obj.get_feature_and_label(testing_set);
            % ytest = obj.color_transform(ytest);
            [label, score] = obj.suplearner.infer(Xtest); % of course we could change it to train bunch of models using 
            obj.evaluate_result(Xtest, ytest, label, testing_set);
            obj.evaluate_score_result(Xtest, ytest, score, testing_set);
            obj.performanceEval.eval(ytest, score, label);
        end


        function k_means_fit(obj, datasets)
            if nargin == 3
                [data_mat, color_types, endpoints, data_windows] = obj.get_feature_and_label(datasets);
            else
                [data_mat, color_types, endpoints, data_windows] = obj.get_feature_and_label();
            end

            transdata = obj.data_transform(data_mat);
            obj.k_means_machine.fit(transdata, data_windows);
            % obj.k_means_machine.show_centroids();
        end



        function k_means(obj, datasets)
            % function for normalize a vector 
            % porp the percentage of correct clustering            
            if nargin == 3
                [data_mat, color_types, endpoints, data_windows] = obj.get_feature_and_label(datasets);
            else
                [data_mat, color_types, endpoints, data_windows] = obj.get_feature_and_label();
            end

            transdata = obj.data_transform(data_mat);
            idx = obj.k_means_machine.infer(transdata);
            figure
            obj.pca_machine.scatter2(data_mat, idx);
            title('kmeans member identification')
            figure
            obj.pca_machine.scatter3(data_mat, idx);
            title('kmeans member identification')
            figure;
            obj.plot_temporal_evolution(datasets, idx);
            title('kmeans member identification')
        
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%adaptations for testingImp
        function [label, score ] = testing_adpt_infer(obj, testing_set)
            [Xtest, ytest] = obj.get_feature_and_label(testing_set);
            % ytest = obj.color_transform(ytest);
            [label, score] = obj.suplearner.infer(Xtest);
        end

        function testing_adpt_eval(obj, label, score, testing_set)
            [Xtest, ytest] = obj.get_feature_and_label(testing_set);
            obj.evaluate_result(Xtest, ytest, label, testing_set);
            obj.evaluate_score_result(Xtest, ytest, score, testing_set);
            obj.performanceEval.eval(ytest, score, label);
        end 

         function clean_train(obj, training_set)
            % learner must confrom to the SupervisedLearnerInterface

            [Xtrain, ytrain] = obj.get_feature_and_label(training_set);    
            % ytrain = obj.color_transform(ytrain);
            % obj.suplearner = feval(learner);
            obj.suplearner.train(Xtrain, ytrain); % of course we could change it to train bunch of models using
            [label, score] = obj.suplearner.infer(Xtrain); 
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% for I/O caching
        function curstudy = get_study_prototype(obj, ind)
            if nargin < 2
                ind = 1;
            end
            if ind > length(obj.EEGStudys)
                error('EEGLearning: get_study_prototype: ind requesting more study than there is')
            end

            curstudy = obj.EEGStudys(ind);

        end

        function save(obj, target_dir)

            study_prototype = obj.get_study_prototype();
            window_prototype = study_prototype.get_window_prototype();
            feature_name = window_prototype.toString();
            [~, data_dir_name] = study_prototype.get_file_name();

            default_dir_name = [data_dir_name, '_', feature_name];
            if nargin == 1
                target_dir = default_dir_name;
            end
            save_dir = [get_myeegcode_dir(), '/tmp/', target_dir]; % NOTE that file is saved to default
            mkdir(save_dir);

            for child_study = obj.EEGStudys

                disp(['saving ', child_study.toString()]);
                child_study.save(save_dir)
            end
        end


        function load(obj, dir_name)
            save_dir = [get_myeegcode_dir(), '/tmp/', dir_name];
            file_listing = dir(save_dir);
            studys = [];
            for file_ind = 1:length(file_listing)
                file = file_listing(file_ind);
                if file.bytes < 1000
                    disp(['empty file:', file.name])
                else
                    cur_file_dir = [save_dir, '/', file.name];
                    disp(['loading file:', file.name]);
                    load(cur_file_dir);
                    saved_obj
                    studys = [studys, saved_obj];
                end
            end
            obj.init(studys);
        end



    end
end
