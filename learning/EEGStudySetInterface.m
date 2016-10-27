classdef EEGStudySetInterface < handle
% I am going to break EEG learning into 2 parts cooperating with each other
% this is the container, i.e data part like model in mvc, it communicates with EEG

    properties
    end

    methods (Abstract)

        %% used to communicate with EEGLearningMachine
        [isEnd, training_data, training_label, cv_data, cv_label] = get_next_fold_of_training_and_cv_data(obj)
       

        [X, label]= get_all_data(obj)


        [X] = get_test_data(obj)

        set_learner(obj, learning_machine) % the learning machine will carry out setting up normalization if it has not been set yet

        train(obj)

        [confidence, predicted_label, true_label, dataset_name] = post_section_processing(obj) % will feed machine test_dataset one by one
                                                                                                % and then predict result


        %% used to communicates with test implementation
        get_num_datasets(obj)

        set_testing_dataset(obj, positive_lis, negative_lis)


        %% I/O
        load_data(obj, path_toData_dir)
        

        save_data(obj, path_toData_dir)
        

        init(obj, opt1, opt2)


    end
end