classdef DataWindowAccum < handle
    properties
        color_codes = [] % stored vertically, i.e each row represent an eg 
        color_types = []
        relative_timestamps = []
        real_timestamps = []
        flattened_features = []
        host_study = [];
        num_channels = 0;
        prototype_window = [];
    end
    methods
        function init(obj, study, num_channels)
            obj.host_study = study;
            obj.num_channels = num_channels;
        end

        function accumulate(obj, curwindow)
            if isempty(obj.prototype_window)
                obj.prototype_window = curwindow;
            end
            obj.color_codes = [obj.color_codes; curwindow.color_code];
            obj.color_types = [obj.color_types; curwindow.get_color_type()];
            obj.relative_timestamps = [obj.relative_timestamps; curwindow.relative_timestamp];
            obj.flattened_features = [obj.flattened_features; curwindow.flattened_feature'];
            obj.real_timestamps = [obj.real_timestamps; curwindow.real_timestamp];
        end

        function num = get_total_num_windows(obj)
            num = length(obj.color_codes);
        end

        function windowData = get_WindowData(obj, ind)
            windowData = WindowData();
            windowData.color_code = obj.color_codes(ind, :);
            windowData.flattened_feature = obj.flattened_features(ind, :)';
            windowData.relative_timestamp = obj.relative_timestamps(ind, :);
            windowData.real_timestamp = obj.real_timestamps(ind, :);
            windowData.color_type = obj.color_types(ind, :);
            windowData.num_channels = obj.num_channels;
        end

        function eegwindow = get_EEGWindow(obj, ind)
            eegwindow = obj.prototype_window.load_window(obj.get_WindowData(ind));
        end
    end
end