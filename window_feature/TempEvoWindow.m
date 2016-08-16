classdef TempEvoWindow < EEGWindowInterface
 
    properties
        child_windows = [];
        child_window;
        child_window_gen = 'EEGWindow3Hz';
    end


    methods

        %% set input data
        function set_raw_feature(obj, input_data, Fs)
            obj.raw_feature = input_data;
            obj.Fs = Fs;
            M = size(input_data,2);

            num_childs = M / Fs;
            for child_ind = 1 : num_childs
                child = feval(obj.child_window_gen);
                cur_mat = input_data(:, (child_ind-1) * Fs + 1: child_ind * Fs);
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
                flattened_feature = [flattened_feature; child.flattened_feature];
            end
            obj.flattened_feature = flattened_feature;
        end






        function plot_feature(obj, feature, opt1)%
            % opt1 is the intensity mapping [min, max], used for comparison
            obj.child_window.plot_feature(feature)

        end 

        function y = get_functional(obj)
            result = 0;
            counter = 0;
            for child_ind = 1 : length(obj.child_windows)
                child = obj.child_windows(child_ind);
                counter = counter + 1;
                result = result + 1;
            end
            y = result / counter;
        end

        function mystr = get_functional_label(obj)
            mystr = obj.child_window.get_functional_label();
        end

    end
end