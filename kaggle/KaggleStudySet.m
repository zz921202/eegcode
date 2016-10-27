classdef KaggleStudySet < handle
% This the data container built specifically for Kaggle dataset
    properties
        section_prototype = []
        capsule_prototype = KaggleDataCapsule()

        pos_capsule_lis = [] 
        neg_capsule_lis = []
        pos_section_lis = []
        neg_section_lis = []

        pos_test_idx_lis = []
        neg_test_idx_lis = []
        pos_available_idx_lis = []
        neg_available_idx_lis = []
        cur_cv_fold = 0
        learning_machine = EEGLearningMachine();
    end

    methods

        % helper method to extract data from multiple section
        function [X, label] = get_data_from_section(obj, sec_idx_lis, kind)

            if strcmp(kind,'positive')
                section_lis = obj.pos_section_lis;
            elif strcmp(kind,'negative')
                section_lis = obj.neg_section_lis;
            else 
                error(['get_data_from_section: unrecognizeed keyword:', kind])
            end
            X = [];
            label = [];
            for idx = sec_idx_lis
                cur_section = section_lis(idx);
                [cur_datamat, cur_label] = cur_section.get_data();
                X = [X; cur_datamat]; %EXPAND MATRIX
                label = [label; cur_label]; % EXPAND LIST
            end
        end

        function [data_mat, label] = get_positive_and_negative_data(obj, pos_lis, neg_lis)
            [pos_data, pos_label] = obj.get_data_from_section(pos_lis, 'positive');
            [neg_data, neg_label] = obj.get_data_from_section(neg_lis, 'negative');
            data_mat = [pos_data; neg_data];
            label = [pos_label, neg_label];
        end


        %% inherent form interface, will be used in conjunction with LearningMachine
        function [isEnd, training_data, training_label, cv_data, cv_label] = get_next_fold_of_training_and_cv_data(obj)
            obj.set_testing_dataset(obj.pos_test_idx_lis, obj.neg_test_idx_lis) % extra work to avoid unintialized available_idx_lis

            isEnd = false;
            if obj.cur_cv_fold == length(obj.pos_available_idx_lis)
                isEnd = true;
                return %Notice that returning parameters has not been set here
            end

            obj.cur_cv_fold = obj.cur_cv_fold + 1;
            pos_cv_idx_lis = [obj.pos_available_idx_lis(obj.cur_cv_fold),];
            neg_cv_idx_lis = [obj.neg_available_idx_lis(obj.cur_cv_fold),];
            pos_train_data_idx_lis = setdiff(obj.pos_available_idx_lis, pos_cv_idx_lis);
            neg_train_data_idx_lis = setdiff(obj.neg_available_idx_lis, neg_cv_idx_lis);
            
            [training_data, training_label] = obj.get_positive_and_negative_data(pos_train_data_idx_lis, neg_train_data_idx_lis);
            [cv_data, cv_label] = obj.get_positive_and_negative_data(pos_cv_idx_lis, neg_cv_idx_lis);

        end


        function [X, label]= get_all_data(obj)
            [X, label] = obj.get_positive_and_negative_data(1:length(pos_section_lis), 1: length(neg_section_lis));
        end


        function [X, label] = get_test_data(obj)
            [X, label] = obj.get_positive_and_negative_data(obj.pos_test_idx_lis, obj.neg_test_idx_lis); 
        end

        function set_learner(obj, learning_machine) % the learning machine will carry out setting up normalization if it has not been set yet
            obj.learning_machine = learning_machine;
            obj.learning_machine.set_studyset(obj);
        end
        
        function train(obj)
            obj.learning_machine.set_studyset(obj);
            obj.learning_machine.reset();
            obj.learning_machine.cv_training();
        end



        %% used to communicates with test implementation
        function [pos_num, neg_num] = get_num_datasets(obj)
            pos_num = length(obj.pos_section_lis);
            neg_num = length(obj.neg_section_lis);
        end

        function set_testing_dataset(obj, positive_lis, negative_lis) % positive list and negative lis idx rather than actual section
            obj.pos_test_idx_lis = positive_lis;
            all_pos_idx = 1: length(obj.pos_section_lis);
            obj.pos_available_section_lis = setdiff(all_pos_idx, positive_lis);

            obj.neg_test_idx_lis = negative_lis;
            all_neg_idx = 1: length(obj.neg_section_lis);
            obj.neg_available_idx_lis = setdiff(all_neg_idx, negative_lis);
        end
        
        function [confidence, predicted_label, true_label, dataset_name] = post_section_processing(obj) % will feed machine test_dataset one by one
                                                                                                % and then predict result
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


        % custom functions used by Kaggle Controller only
        function init(obj, path_to_DataDir, section_prototype) % import data from file system and then organize them into different sections
            obj.section_prototype = section_prototype;
            obj.import_data(path_to_DataDir);
        end
        
        
        %% I/O functions
        function import_data(obj, path_to_DataDir)
            % import data from data_dir and separate them into positive and negative lists
            % then sort it according to its name, alphabetically
            % force a whole recording down the throat of EEG section which carries out data window extraction
            file_listing = dir(path_to_DataDir);

            pos_name_lis = [];
            neg_name_lis = []; % used to form sections for investigation

            for file_ind = 1:length(file_listing)
                file = file_listing(file_ind);
                if file.bytes < 1000 || file.name(1) == '.'
                    disp(['empty file:', file.name])
                else
                    cur_capusle = obj.capsule_prototype.clone();
                    disp(['loading file:', file.name]);
                    load([path_to_DataDir, '/', file.name]);
                    cur_capusle.read_data_structure(dataStruct, file.name);
                    if cur_capusle.is_preictal
                        obj.pos_capsule_lis = [obj.pos_capsule_lis, cur_capusle];
                        pos_name_lis = [pos_name_lis, cur_capusle.idx_name];
                    else
                        obj.neg_capsule_lis = [obj.neg_capsule_lis, cur_capusle];
                        neg_name_lis = [neg_name_lis, cur_capusle.idx_name];
                    end
                end

            end
            
            [~, pos_ind] = sort(pos_name_lis);
            [~, neg_ind] = sort(neg_name_lis);
            obj.pos_capsule_lis = obj.pos_capsule_lis(pos_ind);
            obj.neg_capsule_lis = obj.neg_capsule_lis(neg_ind);

            % generates all positive sections
            temp_section = [];
            old_seq = 0;
            for pos_capusle = obj.pos_capsule_lis
                [isEnd, cur_seq] = pos_capusle.get_sequence_num();
                temp_section = [temp_section, pos_capusle];
                if isEnd % generate section
                    cur_section = obj.section_prototype.clone();
                    cur_section.init(temp_section)
                    obj.pos_section_lis = [obj.pos_section_lis, cur_section];
                    temp_section = [];
                    old_seq = 0;
                else % continue to accumulate capules and check consistency
                    assert(old_seq + 1 == cur_seq, ... 
                        sprintf('capsules must arrive in an increasing order, old is %d, cur is %d, name %s', old_seq, cur_seq, pos_capusle.full_name));
                    old_seq = cur_seq;
                end
            end

            % generates all negative sections
            temp_section = [];
            old_seq = 0;
            for neg_capsule = obj.neg_capsule_lis
                [isEnd, cur_seq] = neg_capsule.get_sequence_num();
                temp_section = [temp_section, neg_capsule];
                if isEnd % generate section
                    cur_section = obj.section_prototype.clone()
                    cur_section.init(temp_section) 
                    obj.neg_section_lis = [obj.neg_section_lis, cur_section];
                    temp_section = [];
                    old_seq = 0;
                else % continue to accumulate capules and check consistency
                    assert(old_seq + 1 == cur_seq, 'capsules must arrive in an increasing order')
                    old_seq = cur_seq;
                end
            end

            obj.pos_capsule_lis = []; % remove capsule to save space and speed up saving
            obj.neg_capsule_lis = []; 

        end


    end
end




















