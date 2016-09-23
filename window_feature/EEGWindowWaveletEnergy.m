classdef EEGWindowWaveletEnergy < EEGWindowInterface
    properties
        band_limits = 25;
        depth = 3; 
        wavelet = 'db3';
    end

    methods
        function new_signal = donw_sampling(obj, sig) % returns a row vector
            sig = double(sig);
            new_signal  = resample(sig, obj.band_limits * 2, obj.Fs);
        end

        function energy = cal_energy(obj, signal)   
            down_signal = obj.donw_sampling(signal);
            [~, energy] = find_all_subbands(down_signal, obj.depth, obj.wavelet);
        end

    end

    methods

        function extract_feature(obj)
            all_sigs = obj.raw_feature;
            feature = [];
            for row = 1: size(all_sigs, 1)
                cur_sig = all_sigs(row, :);
                feature = [feature; obj.cal_energy(cur_sig)];
            end
            obj.flattened_feature = feature(:);
            obj.feature = feature;

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
            curstr = ['EEGWindowBandWaveletEngergy' ,obj.wavelet];
        end
    end
    methods(Access = protected)
        function window_interface = clone_window_and_fill_feature(obj, windowData)
            window_interface = EEGWindowWaveletEnergy();
            nchannels = windowData.num_channels;
            mfeatures = length(windowData.flattened_feature) / nchannels;
            window_interface.feature = reshape(windowData.flattened_feature, [nchannels, mfeatures]);
        end

    end
end