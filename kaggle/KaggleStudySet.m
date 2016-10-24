classdef KaggleStudySet < EEGStudySetInterface
% This the data container built specifically for Kaggle dataset
    properties
        section_prototype = []
        capsule_prototype = KaggleDataCapsule()
        section_lis = []
        pos_capsule_lis = [] 
        neg_capsule_lis = []
        pos_section_lis = []
        neg_section_lis = []
    end

    methods

        %% inherent form interface, will be used in conjunction with LearningMachine
        function [isEnd, training_data, training_label, cv_data, cv_label] = get_next_fold_of_training_and_cv_data(obj)
        end

        function isEnd = move_to_next_train_test_partition(obj)
        end




        function [X, label]= get_all_data(obj)

        end


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




















