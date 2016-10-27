classdef KaggleSection < handle
% This class organize all data capsules belonging to the same recording
% it also allows generation of all data windows and stores them inside data_accum, just like EEGStudy
% also it allows basic exploration technique, like browsing temporally
    properties
        srate = 400
        window_gen = ''
        stride = 0
        window_len = 0
        start_times = []
        data_window_accum = []
        num_windows = 0

        name_dic = {} 
        raw_end_pos = []
        sequence_lis = []
    end

    methods

        function [X, label] = get_data(obj)
            X = obj.data_accum.flattened_features;
            label = obj.data_accum.color_codes;
        end
        function set_window_param(obj, stride, window_len, window_gen) 
            obj.window_gen = window_gen;
            obj.stride = stride;
            obj.window_len = window_len;
            obj.window_gen = window_gen;
        end

        function gen_data_windows(obj, concat_mat, label )

            % generate window location
            
            duration = floor(size(concat_mat, 2) / (obj.srate));
            fprintf('size of current matrix is (%d, %d) with total duration %d \n', size(concat_mat), duration);
            obj.data_window_accum = DataWindowAccum();
            obj.data_window_accum.init(obj, size(concat_mat,1));
            obj.start_times = 0: obj.stride : (duration - obj.window_len);
            obj.num_windows = length(obj.start_times);
            % obj.start_locs = 1:50; % I changed this because compressive sensing is just too slow
            % obj.start_locs
            % obj.EEGData.total_length
            all_windows = {};
            tic
            
            parfor counter = 1: length(obj.start_times)
                start_time = obj.start_times(counter);
                if mod(counter, 500) == 0
                    disp(['......window : ' num2str(counter) '.........'])
                end
                % extract a window obj
                curwindow = feval(obj.window_gen);
                start_loc = start_time * obj.srate + 1;
                end_loc = (start_time + obj.window_len) * obj.srate; 
                raw_feature = concat_mat(:, start_loc: end_loc);
                curwindow.set_raw_feature(raw_feature, obj.srate);
                curwindow.time_info = [start_time, start_time + obj.window_len];
                curwindow.color_code = label;
                curwindow.real_timestamp = start_time;
                curwindow.extract_feature();
                % curwindow
                all_windows{counter} = curwindow;

            end

            for counter = 1: length(obj.start_times)
                curwindow = all_windows{counter};
                obj.data_window_accum.accumulate(curwindow);
            end
            
            toc
            obj.num_windows = length(obj.start_times);

        end

        function init(obj, data_capsules)
            concat_mat = [];
            label = data_capsules(1).is_preictal();
            counter = 0;
            for capsule = data_capsules
                counter = counter + 1;
                obj.name_dic{counter} = capsule.full_name;
                obj.sequence_lis = [obj.sequence_lis, capsule.sequence];
                concat_mat = [concat_mat, capsule.data];
%                 fprintf('extracting from [%d] capsule size of current matrix is (%d, %d) \n', capsule.sequence, size(concat_mat));
                obj.raw_end_pos = [obj.raw_end_pos, size(concat_mat, 2)];
                assert(capsule.is_preictal() == label, 'all capsules in the section must have the same type');
            end
            obj.gen_data_windows(concat_mat, label);
        end


        function section_obj = clone(obj) % clone myself and my parameters for initialization
            section_obj = KaggleSection;
            section_obj.window_gen = obj.window_gen;
            section_obj.window_len = obj.window_len;
            section_obj.stride = obj.stride;
        end


        function plot_temporal_evolution_functional(obj, y)
            % y: user supplied input
            if nargin < 2
                y = [];

                for curwindow_ind = 1 : obj.data_window_accum.get_total_num_windows();
                    curwindow = obj.data_window_accum.get_EEGWindow(curwindow_ind);
                    y = [y, curwindow.get_functional()];
                end

                my_ylabel = curwindow.get_functional_label;
            else
                if obj.num_windows ~= length(y);
                    error('input feature vector are incompatible with current study')
                end

                my_ylabel = 'score';
            end

            figure()
            plot(obj.start_times, y)
            xlabel('time')
            ylabel(my_ylabel)
            title(['temporal evolution' , obj.toString]);
        end

        function plot_temporal_evolution_image(obj)
            y = obj.data_window_accum.flattened_features';
            figure()
            imagesc(y)
            xlabel('time')
            win_proto = obj.get_window_prototype();

            title(sprintf('temporal evolution of %s with range [%d, %d]' , win_proto.toString(), min(min(y)), max(max(y))));
        end
        
        function win = get_window_prototype(obj)
            win = obj.data_window_accum.get_EEGWindow(1);
        end

        function str = toString(obj)
            function substr = get_reasonable_name(name)
                parts = strsplit('.',name);
                substr = parts{1};
            end
            
            str = sprintf('from%sto%s%s', get_reasonable_name(obj.name_dic{1}), get_reasonable_name(obj.name_dic{end}), obj.window_gen)
        end



    end

end