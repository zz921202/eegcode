classdef EEGBrowse % this is just a function for exploration purpose, kind of like a command which holds no data

    methods
        function show(obj,section) % this is generic name to do whatever the name suggests
            section.name
            eegplot(section.get_data(), 'srate', section.get_srate());
        end
    end
end