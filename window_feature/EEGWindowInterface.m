 classdef EEGWindowInterface < handle
    % a data window, concrete class should implement feature extraction 

    properties
        raw_feature % each raw is a channel
        time_info % [strat_time, end_time] used as reference only, to be set directly
        abs_power
        freq
        Fs

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% present after reloading
        color_code % to be used for encoding type of information
        color_type
        feature % normally we should expect a column vector
        flattened_feature
        relative_timestamp
        real_timestamp
    end

    methods
    %% set input data
        function set_raw_feature(obj, input_data, Fs)
            obj.raw_feature = input_data;
            obj.Fs = Fs;
            obj.get_frequency_spectrum();
        end

        function extract_feature(obj)
            obj.feature = obj.raw_feature;
            obj.flattened_feature = obj.raw_feature(:);
        end

        function color_code = get_color_type(obj)
            % interitcal state
            if obj.color_code < 0.1 | obj.color_code > 3.9
                color_code = 0;
            elseif obj.color_code < 2
                color_code = 1 ;% preictal state
            elseif obj.color_code == 2
                color_code = 2 ;
            else
                color_code = 3 ;
            end
        end
        
        function get_frequency_spectrum(obj)
            Fs = obj.Fs;
            cur_data = obj.raw_feature;
            L = size(cur_data, 2);
            NFFT = 2^nextpow2(L); % Next power of 2 from length of y
            Y = fft(cur_data,NFFT, 2)/L;

            obj.freq = Fs/2*linspace(0,1,NFFT/2+1);
            obj.abs_power = 2*abs(Y(:,1:NFFT/2+1));
            
            % Y_sub = filter(1/20 * ones(1,20), 1, Y, [], 2);
            % Plot single-sided amplitude spectrum.
            % plot(f,2*abs(Y_sub(:,1:NFFT/2+1)))

            % title(['Single-Sided Amplitude Spectrum of y(t) at ' num2str(window)])
            % xlabel('Frequency (Hz)')
            % ylabel('|Y(f)|')
        end 

        function plot_my_feature(obj, opt1)
            % most appropriate representation of raw feature
            if nargin == 2
                obj.plot_feature(obj.feature, opt1);
            else
                obj.plot_feature(obj.feature)
            end
        end

        function plot_his_feature(obj, flattened_feature, opt1)
            feature_m = reshape(flattened_feature, size(obj.feature));
            if nargin == 3
                obj.plot_feature(feature_m, opt1);
            else
                obj.plot_feature(feature_m)
            end
        end


        function plot_feature(obj, feature_m, opt1)
            % TODO to be implemented individually
            plot(feature_m);
        end

        function plot_raw_feature(obj)
            raw_feature = obj.raw_feature;
            fs = obj.Fs;
            eegplot(raw_feature, 'srate', fs, 'winlength', size(raw_feature,2)/fs);

        end

        function y = get_functional(obj)
            % TODO
            y = mean(mean(abs(obj.raw_feature)));
        end

        function  mystr = get_functional_label(obj)
            % TODO
            mystr = 'Interface L1 norm'
        end

        function curstr = toString(obj)
            curstr = 'EEGWindowInterface';
        end

        function window_interface = load_window(obj, windowData)
            window_interface = obj.clone_window_and_fill_feature(windowData);
            window_interface.color_code = windowData.color_code;
            window_interface.flattened_feature = windowData.flattened_feature;
            window_interface.relative_timestamp = windowData.relative_timestamp;
            window_interface.real_timestamp = windowData.real_timestamp;
            window_interface.color_type = windowData.color_type;
            window_interface.Fs = obj.Fs;
        end
    end

    methods( Access = protected)
        function window_interface = clone_window_and_fill_feature(obj, windowData)
            window_interface = EEGWindowInterface();
            nchannels = windowData.num_channels;
            mfeatures = length(flattened_feature) / nchannels;
            window_interface.feature = reshape(windowData.flattened_feature, [nchannels, mfeatures]);
        end
        % template pattern, to fill in feature extraction 

        function len = get_flattened_feature_len(obj)
            
            len = length(obj.flattened_feature);
        end
    end

end