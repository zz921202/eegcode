classdef KaggleStudySet < EEGStudySetInterface
% This the data container built specifically for Kaggle dataset
    properties
        section_prototype = []
        capsule_prototype = KaggleDataCapsule()

        pos_filename_cell = {} 
        neg_filename_cell = {}
        pos_section_lis = []
        neg_section_lis = []

        pos_test_idx_lis = []
        neg_test_idx_lis = []
        pos_available_idx_lis = []
        neg_available_idx_lis = []
        cur_cv_fold = 0
        learning_machine = EEGLearningMachine();
        visualize_each_test_section = true;
        max_cv_fold = 4
    end

    methods

        % helper method to extract data from multiple section
        function [X, label, name_cell, endpoint_lis] = get_data_from_section(obj, sec_idx_lis, kind, counts) 
        % counts used to keep track of previous number of entries generated

            if nargin < 4
                counts = 0;
            end

            if strcmp(kind,'positive')
                section_lis = obj.pos_section_lis;
                suffix = 'p';
                fprintf('positive data %d \n', length(sec_idx_lis) );
            elseif strcmp(kind,'negative')
                suffix = 'n';
                section_lis = obj.neg_section_lis;
                fprintf('negative data %d \n', length(sec_idx_lis) );
            else 
                error(['get_data_from_section: unrecognizeed keyword:', kind])
            end
            X = [];
            label = [];
            name_cell = {};
            endpoint_lis = [];

            for idx = sec_idx_lis
                cur_section = section_lis(idx);
                [cur_datamat, cur_label] = cur_section.get_data();
                X = [X; cur_datamat]; %EXPAND MATRIX
                label = [label; cur_label]; % EXPAND LIST
                name_cell = [name_cell, [suffix, cur_section.toStringShort()]]; %EXPAND MATRIX
                counts = counts + size(cur_datamat, 1);
                endpoint_lis = [endpoint_lis, counts];

            end
            disp(name_cell)
        end

        function [data_mat, label, name_cell, endpoint_lis] = get_positive_and_negative_data(obj, pos_lis, neg_lis)
            [pos_data, pos_label, pos_name_cell, pos_endpoints_lis] = obj.get_data_from_section(pos_lis, 'positive');
            [neg_data, neg_label, neg_name_cell, neg_endpoints_lis] = obj.get_data_from_section(neg_lis, 'negative', pos_endpoints_lis(end));
            data_mat = [pos_data; neg_data];
            label = [pos_label; neg_label];
            name_cell = [pos_name_cell, neg_name_cell];
            endpoint_lis = [pos_endpoints_lis, neg_endpoints_lis];
        end


        %% inherent form interface, will be used in conjunction with LearningMachine
        function [isEnd, training_data, training_label, cv_data, cv_label] = get_next_fold_of_training_and_cv_data(obj)
            obj.set_testing_dataset(obj.pos_test_idx_lis, obj.neg_test_idx_lis) % extra work to avoid unintialized available_idx_lis

            isEnd = false;
            if obj.cur_cv_fold == obj.max_cv_fold;
                isEnd = true;
                training_data = [];
                training_label = [];
                cv_data = [];
                cv_label = [];
                return %Notice that returning parameters has not been set here
            end

            pos_increment = floor(length(obj.pos_available_idx_lis) / obj.max_cv_fold);


            prev_start = obj.cur_cv_fold * pos_increment + 1;
            obj.cur_cv_fold = obj.cur_cv_fold + 1;
            pos_cv_idx_lis = obj.pos_available_idx_lis(prev_start : obj.cur_cv_fold * pos_increment);
            neg_cv_idx_lis = obj.neg_available_idx_lis(prev_start : obj.cur_cv_fold * pos_increment); % a single element is still iterabel inside matlab
            pos_train_data_idx_lis = setdiff(obj.pos_available_idx_lis, pos_cv_idx_lis);
            neg_train_data_idx_lis = setdiff(obj.neg_available_idx_lis, neg_cv_idx_lis);
            
            [training_data, training_label] = obj.get_positive_and_negative_data(pos_train_data_idx_lis, neg_train_data_idx_lis);
            [cv_data, cv_label] = obj.get_positive_and_negative_data(pos_cv_idx_lis, neg_cv_idx_lis);

        end


        function [X, label, name_cell, endpoint_lis]= get_all_data(obj)
            [X, label, name_cell, endpoint_lis] = obj.get_positive_and_negative_data(1:length(obj.pos_section_lis), 1: length(obj.neg_section_lis));
        end


        function [X, label] = get_test_data(obj)
            [X, label] = obj.get_positive_and_negative_data(obj.pos_test_idx_lis, obj.neg_test_idx_lis); 
        end

        function set_learner(obj, learning_machine) % the learning machine will carry out setting up normalization if it has not been set yet
            obj.learning_machine = learning_machine;
            obj.learning_machine.set_studyset(obj);
        end
        

        function cv_train(obj)
            
            obj.learning_machine.cv_training();
        end

        function train(obj)
            obj.learning_machine.train();
        end

        
        function [train_data, train_label, name_cell, endpoint_lis] = get_all_training_data(obj)
            [train_data, train_label, name_cell, endpoint_lis] = obj.get_positive_and_negative_data(obj.pos_available_idx_lis, obj.neg_available_idx_lis); 
        end

        function new_training_cycle(obj)
            obj.cur_cv_fold = 0;
        end


        %% used to communicates with test implementation
        function [pos_num, neg_num] = get_num_datasets(obj)
            pos_num = length(obj.pos_section_lis);
            neg_num = length(obj.neg_section_lis);
        end

        function set_testing_dataset(obj, positive_lis, negative_lis) % positive list and negative lis idx rather than actual section
            obj.pos_test_idx_lis = positive_lis;
            all_pos_idx = 1: length(obj.pos_section_lis);
            obj.pos_available_idx_lis = setdiff(all_pos_idx, positive_lis);

            obj.neg_test_idx_lis = negative_lis;
            all_neg_idx = 1: length(obj.neg_section_lis);
            obj.neg_available_idx_lis = setdiff(all_neg_idx, negative_lis);
        end
        
        function [confidence_array, predicted_label_array, true_label_array, dataset_name_cell] = post_processing(obj) 
            % will feed machine test_dataset one by one
            % and then predict result, used for both testing and evaluation of performance of current machine
            confidence_array = [];
            predicted_label_array = [];
            true_label_array = [];
            dataset_name_cell = {};

            to_test_section_array = [obj.pos_section_lis(obj.pos_test_idx_lis), obj.neg_section_lis(obj.neg_test_idx_lis)];
            for section = to_test_section_array
                [curX, ~] = section.get_data();
                [label, score] = obj.learning_machine.predict(curX);
                [cur_confidence, cur_pred_label, cur_true_label, cur_dataset_names ] = section.post_processing(score, label, obj.visualize_each_test_section);

                predicted_label_array = [predicted_label_array; cur_pred_label]; % EXPAND ARRAY
                confidence_array = [confidence_array; cur_confidence]; % EXPAND ARRAY
                true_label_array = [true_label_array; cur_true_label]; % EXPAND ARRAY
                dataset_name_cell = [dataset_name_cell, cur_dataset_names]; %EXPAND CELL
            end

        end

        %%
        function load_data(obj, load_dir)
            obj.pos_section_lis = [];
            obj.neg_section_lis = [];

            pos_dir = sprintf('%s/pos/', load_dir);
            neg_dir = sprintf('%s/neg/', load_dir);

            pos_file_listing = dir(pos_dir);

            for file_ind = 1:length(pos_file_listing)
                file = pos_file_listing(file_ind);
                if file.bytes < 1000
                    disp(['empty file:', file.name])
                else
                    disp(['loading file:', file.name]);
                    file_path = [pos_dir, file.name];
                    load(file_path);
                    obj.pos_section_lis = [obj.pos_section_lis, pos_section];
                end
            end

            neg_file_listing = dir(neg_dir);
            for file_ind = 1: length(neg_file_listing)
                file = neg_file_listing(file_ind);
                if file.bytes < 1000
                    disp(['empty file:', file.name])
                else
                    disp(['loading file:', file.name]);
                    file_path = [neg_dir, file.name];
                    load(file_path);
                    obj.neg_section_lis = [obj.neg_section_lis, neg_section];
                end
            end
        end


        function save_data(obj, save_dir) % I will keep it simple, but controller should add more information to it to make it precise
            mkdir(save_dir); % just save all sections
            pos_dir = sprintf('%s/pos/', save_dir);
            neg_dir = sprintf('%s/neg/', save_dir);
            mkdir(pos_dir)
            mkdir(neg_dir)
            tic
            disp('starting to save positive ')
            for pos_section = obj.pos_section_lis
                save([pos_dir, pos_section.toString()],'pos_section');
            end
            toc
            tic
            disp('starting to save negative ')
            for neg_section = obj.neg_section_lis
                save([neg_dir, neg_section.toString()], 'neg_section');
            end
            toc
        end


        % custom functions used by Kaggle Controller only %TO BE DEPRECATED
        function init(obj, path_to_DataDir, section_prototype) % import data from file system and then organize them into different sections
            obj.section_prototype = section_prototype;
            obj.import_data(path_to_DataDir);
        end
        
        
        %% I/O functions
        function import_data(obj, path_to_DataDir)
            % import data from data_dir and separate them into positive and negative lists
            % then sort it according to its name, alphabetically
            % force a whole recording down the throat of EEG section which carries out data window extraction

            %revision: nov 03 to speed up, perfomr feature extraction batch hour by hour rather than extracting alll
            file_listing = dir(path_to_DataDir);

            pos_name_lis = [];
            neg_name_lis = []; % used to form sections for investigation

            function cur_capusle = get_capsule(file_name) % get an capsule based on filename
                cur_capusle = obj.capsule_prototype.clone();
                disp(['loading file:', file_name]);
                curpath = [path_to_DataDir, '/', file_name];
                load_struct = load(curpath);
                cur_capusle.read_data_structure(load_struct.dataStruct, file_name);
            end

            for file_ind = 1:length(file_listing)
                file = file_listing(file_ind);
                if file.bytes < 1000 || file.name(1) == '.'
                    disp(['empty file:', file.name])
                else
                    % cur_capusle = get_capsule(file.name);
                    [idx_name, pre_ictal] = obj.capsule_prototype.get_idx_name(file.name)
                    if pre_ictal
                        obj.pos_filename_cell = [obj.pos_filename_cell, file.name];
                        pos_name_lis = [pos_name_lis, idx_name]; %EXPAND ARRAY
                    else
                        obj.neg_filename_cell = [obj.neg_filename_cell, file.name];
                        neg_name_lis = [neg_name_lis, idx_name]; %EXPAND ARRAY
                    end
                end

            end
            
            [~, pos_ind] = sort(pos_name_lis);
            [~, neg_ind] = sort(neg_name_lis);
            obj.pos_filename_cell = obj.pos_filename_cell(pos_ind);
            obj.neg_filename_cell = obj.neg_filename_cell(neg_ind);

            % generates all positive sections
            temp_section = [];
            old_seq = 0;
            for filename_cell = obj.pos_filename_cell
                pos_capusle = get_capsule(filename_cell{1});
                [isEnd, cur_seq] = pos_capusle.get_sequence_num();
                temp_section = [temp_section, pos_capusle]; %EXPAND ARRAY
                if isEnd % generate section
                    cur_section = obj.section_prototype.clone();
                    cur_section.init(temp_section)
                    obj.pos_section_lis = [obj.pos_section_lis, cur_section];
                    temp_section = [];
                    old_seq = 0;
                    fprintf('processing %s', cur_section.toString());
                else % continue to accumulate capules and check consistency
                    assert(old_seq + 1 == cur_seq, ... 
                        sprintf('capsules must arrive in an increasing order, old is %d, cur is %d, name %s', old_seq, cur_seq, pos_capusle.full_name));
                    old_seq = cur_seq;
                end
            end

            % generates all negative sections
            temp_section = [];
            old_seq = 0;
            for filename_cell = obj.neg_filename_cell
                neg_capsule = get_capsule(filename_cell{1});
                [isEnd, cur_seq] = neg_capsule.get_sequence_num();
                temp_section = [temp_section, neg_capsule]; %EXPAND ARRAY
                if isEnd % generate section
                    cur_section = obj.section_prototype.clone();
                    cur_section.init(temp_section) 
                    obj.neg_section_lis = [obj.neg_section_lis, cur_section];
                    temp_section = [];
                    old_seq = 0;
                else % continue to accumulate capules and check consistency
                    assert(old_seq + 1 == cur_seq, 'capsules must arrive in an increasing order')
                    old_seq = cur_seq;
                end
            end

            obj.pos_filename_cell = []; % remove capsule to save space and speed up saving
            obj.neg_filename_cell = []; 

        end

        function set_section_prototype(obj, section_prototype)
            obj.section_prototype = section_prototype;
        end


    end
end




















