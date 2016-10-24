classdef WaveletBrowse % this is just a function for exploration purpose, kind of like a command which holds no data

    methods
        function show(obj, section) % this is generic name to do whatever the name suggests
            % just plot the fft of all like 
            section.name
            ncahnnels = size(section.data, 1);

            for chn = 1: ncahnnels
                subplot(ncahnnels/2, 2, chn)
                cwt(section.data(chn, :), 1:8, 'db3', 'plot');
            end
        end
    end
end