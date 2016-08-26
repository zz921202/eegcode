classdef EEGWindowBandCrossPowerSpectrum < EEGWindowBandCoherence
    methods(Access = protected)

        function mcoh = normalize(obj, pxy2, pxx)
                mcoh = log(pxy2 + ones(size(pxy2)) * 1e-6);
        end


    end

    methods
        function curstr = toString(obj)
            curstr = 'EEGWindowBandCrossPowerSpectrum';
        end
    end
end