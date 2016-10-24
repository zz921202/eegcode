classdef TempEvoWindow < EEGWindowInterface
 
    properties
        child_windows = [];
        child_window;
        child_window_gen = 'EEGWindowWaveletEnergy';
        window_length = 2;
        num_childs = 0;
    end


    methods

        %% set input data
        function set_raw_feature(obj, input_data, Fs)
            obj.raw_feature = input_data;
            obj.Fs = Fs;
            M = size(input_data,2);

            obj.num_childs = M / (Fs * obj.window_length);

            for child_ind = 1 : obj.num_childs
                child = feval(obj.child_window_gen);
                cur_mat = input_data(:, (child_ind-1) * Fs + 1: child_ind * Fs); % One second window
                child.set_raw_feature(cur_mat, Fs);

                obj.child_windows = [obj.child_windows, child];
            end

            obj.child_window = obj.child_windows(1);
        end

        function extract_feature(obj)
            obj.child_window.extract_feature()
            flattened_feature = [];

            for child_ind = 1 : length(obj.child_windows)
                child = obj.child_windows(child_ind);
                child.extract_feature();
                
            end
            
            
            for child_ind = 1: length(obj.child_windows)
                child = obj.child_windows(child_ind);
                flattened_feature = [flattened_feature; child.flattened_feature];
            end

            obj.flattened_feature = flattened_feature;
        end






        function plot_feature(obj, feature, opt1)%
            % opt1 is the intensity mapping [min, max], used for comparison
            obj.child_window.plot_feature(feature)

        end 

        function y = get_functional(obj)
            y = mean(obj.flattened_feature);
            if mod(obj.real_timestamp, 200) == 0
                obj.real_timestamp
            end
        end

        function mystr = get_functional_label(obj)
            mystr = obj.child_window.get_functional_label();

        end

        function curstr = toString(obj)
            curstr = ['TempEvo' , obj.child_window.toString()];
        end

    end

    
    methods(Access = protected)

        function window_interface = clone_window_and_fill_feature(obj, windowData)
            window_interface = TempEvoWindow();
            % warning('TempEvoWindow supports recreation now, but not fully tested')
            % nchannels = windowData.num_channels;
            % mfeatures = length(flattened_feature) / nchannels;
            % window_interface.feature = reshape(windowData.flattened_feature, [nchannels, mfeatures]);
        

            flattened_feature = windowData.flattened_feature;
            used_ele = 0;
            win_child_windows = [];
            for child_ind = 1: length(obj.child_windows)
                child = obj.child_windows(child_ind);
                cur_flattened_feature = flattened_feature(used_ele + 1: used_ele + child.get_flattened_feature_len);
                child_window_data = windowData.set_flattened_feature(cur_flattened_feature);

                win_child_windows = [win_child_windows, child.load_window(child_window_data)];

            end
            window_interface.child_windows = win_child_windows;
            window_interface.child_window = win_child_windows(1);
            window_interface.num_childs = obj.num_childs;

        end

    end
end