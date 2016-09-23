classdef WindowData < handle

    % just a container class to encapsulate parameters for window recreation
    properties
        color_code
        color_type
        relative_timestamp
        real_timestamp
        flattened_feature
        num_channels
        seizure_timestamp
    end
    methods
        function windowData = set_flattened_feature(obj, flattened_feature)
            windowData = WindowData();
            windowData.color_code = obj.color_code;
            windowData.flattened_feature = flattened_feature;
            windowData.relative_timestamp = obj.relative_timestamp;
            windowData.real_timestamp = obj.real_timestamp;
            windowData.color_type = obj.color_type;
            windowData.num_channels = obj.num_channels;
            windowData.seizure_timestamp = obj.seizure_timestamp;
        end
    end
end 