classdef SortedAmplitudeWindow < EEGWindowInterface
    properties
        child_window = EEGWindow3Hz()
    end


    methods

        %% set input data
        function set_raw_feature(obj, input_data, Fs)
            obj.raw_feature = input_data;
            obj.Fs = Fs;
            obj.child_window.set_raw_feature(input_data, Fs)
        end

        function extract_feature(obj)
            obj.child_window.extract_feature()
            obj.flattened_feature = sort(obj.child_window.flattened_feature);
        end






        function plot_feature(obj, feature, opt1)%
            % opt1 is the intensity mapping [min, max], used for comparison
            obj.child_window.plot_feature(feature)

        end 

        function y = get_functional(obj)
            y = obj.child_window.get_functional();
        end

        function mystr = get_functional_label(obj)
            mystr = obj.child_window.get_functional_label();
        end

        function curstr = toString(obj)
            curstr = ['EEGSortedAmplitude', obj.child_window.toString()] ;
        end

    end
    methods(Access = protected)

        function window_interface = clone_window_and_fill_feature(obj, windowData)
            window_interface = SortedAmplitudeWindow();
            warning('reconstruction of feature is not possible for SortedAmplitudeWindow')
        end

    end
end