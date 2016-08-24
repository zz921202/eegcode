classdef EEGCompositeWindow < EEGWindowInterface
 
    properties
        child_windows = {EEGWindow3Hz(), EEGWindowBandCoherence(), EEGWindowBandAmplitude()};
        prototype_window;
    end


    



    methods

        function set_prototype_window(obj, ind)
            if nargin < 2
                ind = 1;
            end
            obj.prototype_window = obj.child_windows{ind};
        end

        %% set input data
        function set_raw_feature(obj, input_data, Fs)
            obj.raw_feature = input_data;
            obj.Fs = Fs;
            for child_ind = 1: length(obj.child_windows)
                % child_ind
                child = obj.child_windows{child_ind};
                % child
                child.set_raw_feature(input_data, Fs);
            end
            obj.set_prototype_window()
        end

        function extract_feature(obj)

            flattened_feature = [];
            for child_ind = 1: length(obj.child_windows)

                child = obj.child_windows{child_ind};
                child.extract_feature();
                flattened_feature = [flattened_feature; child.flattened_feature];
            end
            obj.flattened_feature = flattened_feature;
        end

        function plot_feature(obj, feature, opt1)%
            % opt1 is the intensity mapping [min, max], used for comparison
            obj.prototype_window.plot_feature(feature);

        end 

        function y = get_functional(obj)
            y = obj.prototype_window.get_functional();
        end

        function mystr = get_functional_label(obj)
            mystr = obj.prototype_window.get_functional_label();
        end


        %% support for ensemble2compositeAdpt

        function num = get_num_children(obj)
            num = length(obj.child_windows);
        end

        function [startind, endind] = get_child_feature_ind(obj, k)
            startind = 0;
            for ind = 1:k -1
                curwin = obj.child_windows{ind};
                startind =  startind  + length(curwin.flattened_feature);
            end
            lastwin = obj.child_windows{k};
            endind = startind  + length(lastwin.flattened_feature);
            startind = startind + 1;
        end

        function curstr = toString(obj)

            curstr = 'Composite_';
            for child_ind = 1: length(obj.child_windows)

                child = obj.child_windows{child_ind};
                curstr = [curstr, '_', child.toString()];
            end
        end

    end

    methods(Access = protected)
    
        function window_interface = clone_window_and_fill_feature(obj, windowData)
            window_interface = EEGCompositeWindow();
            flattened_feature = windowData.flattened_feature;
            used_ele = 0;
            win_child_windows = {};
            for child_ind = 1: length(obj.child_windows)
                child = obj.child_windows{child_ind};
                cur_flattened_feature = flattened_feature(used_ele + 1: used_ele + child.get_flattened_feature_len);
                child_window_data = windowData.set_flattened_feature(cur_flattened_feature);

                win_child_windows{child_ind} = child.load_window(child_window_data);

            end
            window_interface.child_windows = win_child_windows;
            window_interface.set_prototype_window();
        end
    end
    
end