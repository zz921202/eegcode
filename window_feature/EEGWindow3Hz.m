classdef EEGWindow3Hz < EEGWindowInterface
    properties
        band_limits = [2, 4];
    end

    methods(Access = private)
        function cur_power = get_power(obj, low_cutoff, high_cutoff)
            test_cond = @(freq) and(freq >= low_cutoff, freq < high_cutoff);
            indicator = arrayfun(test_cond, obj.freq);
            cur_power = sum((obj.abs_power(:,indicator)), 2) / (high_cutoff - low_cutoff);
        end
    end


    methods

        function extract_feature(obj)
            feature = [];
            band_cutoffs = obj.band_limits;
            for i = 1:length(band_cutoffs)-1
                feature = [feature,  obj.get_power(band_cutoffs(i), band_cutoffs(i + 1))];
            end
            obj.feature = feature; 
            obj.flattened_feature = feature(:);
        end






        function plot_feature(obj, feature, opt1)%
            % opt1 is the intensity mapping [min, max], used for comparison
            ah1 = axes;
            imagesc(feature);
            if nargin == 3
                caxis(ah1,opt1)
            end
            colorbar;

        end 

        function y = get_functional(obj)
            y = mean(abs(obj.flattened_feature));
        end

        function mystr = get_functional_label(obj)
            mystr = 'l1 norm';
        end

        function curstr = toString(obj)
            curstr = 'EEGWindow3Hz';
        end
    end
    
    methods(Access = protected)
        function window_interface = clone_window_and_fill_feature(obj, windowData)
            window_interface = EEGWindow3Hz();
            nchannels = windowData.num_channels;
            mfeatures = length(windowData.flattened_feature) / nchannels;
            window_interface.feature = reshape(windowData.flattened_feature, [nchannels, mfeatures]);
        end


    end
end