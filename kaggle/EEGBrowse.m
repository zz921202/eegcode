classdef EEGBrowse % this is just a function for exploration purpose, kind of like a command which holds no data

    methods
        function show(obj,data_mat) % this is generic name to do whatever the name suggests

            eegplot(data_mat, 'srate', 400);
        end
    end
end