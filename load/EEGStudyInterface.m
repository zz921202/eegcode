classdef EEGStudyInterface < handle
    % overall flow of one study
    % concrete class includes specific eegdata 
    % 
    properties
        data_windows = [] % an array that saves all data windows
        EEGData % source data file, handles I/O
        start_locs
        window_length

        num_windows
        window_generator = 'EEGWindowInterface'
        stride
        % used to indicate the class that current window belongs to 
        
%         S = []          % should consider
%         V = []% used to store result from pca
%         idx
%         C
%         pca_coordinates

        classifier_label_imp = IctalInterictalLabel();
    end

    methods (Access = protected)

        function gen_data_windows(obj, opt1)
            %opt1 for parallel programming 

            % generate window location
            obj.start_locs = 0: obj.stride : (obj.EEGData.total_length - obj.window_length);
            %obj.start_locs = [ 2000,  2990, 3000, 3040, 3100]; % I changed this because compressive sensing is just too slow
            counter = 0;
            % obj.start_locs
            % obj.EEGData.total_length
            for start_loc = obj.start_locs
                counter = counter + 1;
                if mod(counter, 500) == 0
                    disp(['......window : ' num2str(counter) '.........'])
                end

                curwindow = feval(obj.window_generator);
                obj.EEGData.gen_raw_window(start_loc, obj.window_length, curwindow); %TODO changed backed to raw window
                obj.data_windows = [obj.data_windows, curwindow];

            end

            obj.num_windows = length(obj.start_locs);

        end


    end

    methods

        function import_data(obj, data_file, dataset_name, seizure_times)
            % opt1 import data file
            % opt2 import dataset name
            % opt3 seizure times mx2 matrix

            if nargin == 1
                opt1 = '/Users/Zhe/Documents/seizure/myeegcode/test_MIT_Data/test_MIT_rejected.set';
                opt2 = 'test_MIT';
                opt3 = [2996, 3036];
            %  maybe rather than subclassing, change to just function calls, 
            % but I guess it might be a sensible thing to do when there are some many parameters to set
            end
            obj.EEGData = EEGDataMIT();

            obj.EEGData.load_set(data_file);
            obj.EEGData.set_name(dataset_name, 'CHB_MIT');
            obj.EEGData.seizure_times = seizure_times;


        end

        function browse_raw(obj)
            obj.EEGData.browse_raw();
        end


        function set_window_params(obj, window_length, stride, window_generator)
            obj.window_length = window_length;
            obj.stride = stride;
            obj.window_generator = window_generator;
            obj.gen_data_windows();

        end


        %% helper functions, to be called inside each subclass


        function [cur_feature_matrix, cur_color_types, cur_color_codes, cur_data_windows] = get_feature_matrix(obj)
            % pull extracted features from each eeg window to form a matrix for fitting
            % ASSUME that we are using flattened column vector features
            % we would not use that for ,say, convolution neural network(CNN)
            cur_feature_matrix = [];
            cur_color_codes = [];
            cur_color_types = [];
            cur_data_windows = [];
            for cur_window  = obj.data_windows
                [label, toInclude] = obj.classifier_label_imp.get_label(cur_window);
                if toInclude
                    cur_feature_matrix = [cur_feature_matrix, cur_window.flattened_feature];
                    cur_window_color_codes = cur_window.get_color_type();
                    cur_color_codes = [cur_color_codes, cur_window_color_codes];
                    cur_color_types = [cur_color_types, label];
                    % cur_data_windows = [cur_data_windows, cur_window];
                end
            end
            cur_color_types = cur_color_types(:);
            cur_color_codes = cur_color_codes(:);
            cur_feature_matrix = cur_feature_matrix';
        end



        function y = plot_temporal_evolution(obj, opt1)
            % opt1 supports foreign vectors, say the classification result from svm etc
            if nargin < 2
                y = [];
                for curwindow = obj.data_windows
                    y = [y, curwindow.get_functional()];
                    
                end
                my_ylabel = curwindow.get_functional_label;
            else
                if obj.num_windows ~= length(opt1);
                    error('input feature vector are incompatible with current study')
                end
                y = opt1;
                my_ylabel = 'score';
            end


            figure()

            plot(obj.start_locs, y)
            xlabel('time')
            ylabel(my_ylabel)
            title(['temporal evolution' , obj.toString]);
            for row = size(obj.EEGData.seizure_times, 1)
                for marker = obj.EEGData.seizure_times(row, :)
                    line([marker, marker], ylim, 'color','red')
                end
            end

        end

        %% standard functionalities
        function mystr = toString(obj)
            mystr = [class(obj) ' '  num2str(obj.num_windows) ' of ' num2str(obj.window_length) ' sec ' obj.window_generator ...
                              ' from ' obj.EEGData.toString];
        end


        
    end
end