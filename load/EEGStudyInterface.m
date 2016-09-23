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


        classifier_label_imp = IctalInterictalLabel();
        default_label_imp = StudyClassifierLabelInterface();
        data_dir_name = '';
        data_file_name = '';
        data_window_accum = [];

    end

    methods (Access = protected)

        function gen_data_windows(obj, opt1)
            %opt1 for parallel programming 

            % generate window location
            obj.start_locs = 0: obj.stride : (obj.EEGData.total_length - obj.window_length);
            % obj.start_locs = 1:50; % I changed this because compressive sensing is just too slow
            counter = 0;
            % obj.start_locs
            % obj.EEGData.total_length
            all_windows = {};
            tic
            parfor counter = 1: length(obj.start_locs)
                start_loc = obj.start_locs(counter)
                if mod(counter, 500) == 0
                    disp(['......window : ' num2str(counter) '.........'])
                end
                curwindow = feval(obj.window_generator);
                
                obj.EEGData.gen_raw_window(start_loc, obj.window_length, curwindow);
                % curwindow
                all_windows{counter} = curwindow;
            end

            for counter = 1: length(obj.start_locs)
                curwindow = all_windows{counter};
                obj.data_window_accum.accumulate(curwindow);
            end
            

            % for start_loc = obj.start_locs
            %     counter = counter + 1;
            %     if mod(counter, 500) == 0
            %         disp(['......window : ' num2str(counter) '.........'])
            %     end

            %     curwindow = feval(obj.window_generator);
            %     obj.EEGData.gen_raw_window(start_loc, obj.window_length, curwindow);  %changed backed to raw window
            %     % obj.data_windows = [obj.data_windows, curwindow]; 
            %     obj.data_window_accum.accumulate(curwindow);

            % end
            toc
            obj.num_windows = length(obj.start_locs);

        end


    end

    methods

        function import_data(obj, data_file, dataset_name, seizure_times) % Init method
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
            obj.data_window_accum = DataWindowAccum();
            obj.data_window_accum.init(obj, obj.EEGData.get_num_channels);
            obj.EEGData.set_name(dataset_name, 'CHB_MIT');
            obj.EEGData.seizure_times = seizure_times;
            [cur_dir, obj.data_file_name] = fileparts(data_file);
            [~, obj.data_dir_name] = fileparts(cur_dir);  

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


        function [cur_feature_matrix, cur_color_types, cur_color_codes, cur_data_windows] = get_feature_matrix(obj, training)
            % pull extracted features from each eeg window to form a matrix for fitting
            % ASSUME that we are using flattened column vector features
            % we would not use that for ,say, convolution neural network(CNN)
            cur_feature_matrix = [];
            cur_color_codes = [];
            cur_color_types = [];
            cur_data_windows = [];
            % for cur_window  = obj.data_windows 
            if nargin < 2
                for curwindow_ind = 1 : obj.data_window_accum.get_total_num_windows();
                    cur_window = obj.data_window_accum.get_WindowData(curwindow_ind);

                    [label, toInclude] = obj.default_label_imp.get_label(cur_window);
                    if toInclude
                        cur_feature_matrix = [cur_feature_matrix, cur_window.flattened_feature];


                        cur_window_color_codes = cur_window.color_type(); % NOTICE the change of notation here from color_type of window ==> color_codes
                        cur_color_codes = [cur_color_codes, cur_window_color_codes];
                        cur_color_types = [cur_color_types, label];
                    end
                end
            else

                 for curwindow_ind = 1 : obj.data_window_accum.get_total_num_windows();
                    cur_window = obj.data_window_accum.get_WindowData(curwindow_ind);

                    [label, toInclude] = obj.classifier_label_imp.get_label(cur_window);
                    if toInclude
                        cur_feature_matrix = [cur_feature_matrix, cur_window.flattened_feature];


                        cur_window_color_codes = cur_window.color_type(); % NOTICE the change of notation here from color_type of window ==> color_codes
                        cur_color_codes = [cur_color_codes, cur_window_color_codes];
                        cur_color_types = [cur_color_types, label];
                    end
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

                for curwindow_ind = 1 : obj.data_window_accum.get_total_num_windows();
                    curwindow = obj.data_window_accum.get_EEGWindow(curwindow_ind);
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


        function [file_name , dir_name] = get_file_name(obj)
            file_name = obj.data_file_name;
            dir_name = obj.data_dir_name;
        end


        function eeg_window = get_window_prototype(obj, ind)
            if nargin < 2
                ind = 1;
            end
            % if ind > length(obj.data_windows)
            if ind > obj.data_window_accum.get_total_num_windows
                error('EEGStudyInterface: get_window_prototype: ind requesting more study than there is')
            end
            eeg_window = obj.data_window_accum.get_EEGWindow(ind);
        end

        function save(obj, data_dir)
            save_name = [data_dir, '/', obj.data_file_name];
            saved_obj =  obj;
            save(save_name, 'saved_obj');
        end


    end
end