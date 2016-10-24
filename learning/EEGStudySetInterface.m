classdef EEGStudySetInterface < handle
% I am going to break EEG learning into 2 parts cooperating with each other
% this is the container, i.e data part like model in mvc, it communicates with EEG

    properties
    end

    methods (Abstract)
        [isEnd, training_data, training_label, cv_data, cv_label] = get_next_fold_of_training_and_cv_data(obj)
       

        isEnd = move_to_next_train_test_partition(obj)
        

        load_data(obj, path_toData_dir)
        

        save_data(obj, path_toData_dir)
        

        init(obj, opt1, opt2)

        [X, label]= get_all_data(obj)


    end
end