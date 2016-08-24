classdef EEGWindowBandCoherence < EEGWindowInterface

    properties(Constant)
        band_cutoff = [30,40] % to be set as a static parameter
    end

    properties
        
        cxy
        
        num_windows = 4;
        shrink_factor = 2;
    end
    
    methods(Static)
        
        function cur_power = get_coherence_band_sum(cxy, f)
            low_cutoff = EEGWindowBandCoherence.band_cutoff(1);
            high_cutoff = EEGWindowBandCoherence.band_cutoff(2);
            test_cond = @(freq) and(freq >= low_cutoff, freq < high_cutoff);
            indicator = arrayfun(test_cond, f);

            cur_power = sum((cxy(indicator))) / sum(indicator);
        end
        
        function filtered_amp = band_filter(c_m, f)
            low_cutoff = EEGWindowBandCoherence.band_cutoff(1);
            high_cutoff = EEGWindowBandCoherence.band_cutoff(2);
            test_cond = @(freq) and(freq >= low_cutoff, freq < high_cutoff);
            indicator = arrayfun(test_cond, f);
            
            filtered_amp = c_m(:, indicator);
        end
        

    end
    
    methods
        function mcoh = mscoh_extract(obj)
            
            dim = size(obj.raw_feature, 1);
            feature = zeros(dim,dim);
            raw_feature = obj.raw_feature;
            for i = 1:dim
            % for i = 1:dim
                
                curfeature = zeros(1,dim);
                for j= (i + 1): dim
%                     i = i
%                     j = j
                    x = raw_feature(i, :);
                    y = raw_feature(j, :);
                    [curcxy, f] = cpsd(x,y,[],[],[],obj.Fs);
                    pxx = pwelch(x, [], [], [], obj.Fs);
                    pyy = pwelch(y, [], [], [], obj.Fs);
                    figure()
                    hold on
                    plot(f, abs(curcxy), 'Marker', 'x');
                    
                    plot(f, pxx);
                    plot(f, pyy);
%                     legend('cross', 'xx', 'yy');
                    title(sprintf('x: %d, y: %d', i, j));
                    hold off
                    
                    sumcxy = EEGWindowBandCoherence.get_coherence_band_sum(curcxy, f);
                    sumpxy = EEGWindowBandCoherence.get_coherence_band_sum(pxx, f) * EEGWindowBandCoherence.get_coherence_band_sum(pyy, f) ;
                    
                    curfeature(j) = abs(sumcxy).^2 / (sumpxy);
%                     feature(j,i) = val;
                end
                feature(i, :)= curfeature;
            end
 
            mcoh = feature + eye(dim) + feature';
            
        end
        
        
        function cur_mcoh = extract_single_window(obj, cur_matrix)
            Fs = obj.Fs;
            
            L = size(cur_matrix, 2);
            NFFT = 2^nextpow2(L); % Next power of 2 from length of y
            Y = fft(cur_matrix,NFFT, 2)/L;
            Y= Y(:,1:NFFT/2+1);
            freq = Fs/2 * linspace(0,1,NFFT/2+1);

%             plot(freq, abs(Y(1,:)));
            filtered_amp_m = EEGWindowBandCoherence.band_filter(Y, freq); % change to absolute value, shoudl not affect cal
            
            cur_mcoh = abs(filtered_amp_m * ctranspose(filtered_amp_m));
        end
        
        function mcoh = fast_extraction(obj)
            M = size(obj.raw_feature, 2);
            step_size = size(obj.raw_feature, 2) / obj.num_windows;
            window_len = M / obj.shrink_factor;
            raw_feature = obj.raw_feature;
            
            dim = size(obj.raw_feature, 1);
            feature = zeros(dim,dim);
            
            for start_ind = 1: step_size: (M - window_len + 1)
                end_ind = start_ind + window_len - 1;
               
%                 end_ind
                cur_window = raw_feature(:, start_ind:end_ind);
%                 increment = obj.extract_single_window(cur_window)
                feature = feature + obj.extract_single_window(cur_window);
            end
            tempcxy = diag(feature) * diag(feature)' ;
            if norm(tempcxy) < 1e-5
                disp(feature)
                disp(obj.real_timestamp)
            end
            mcoh = feature.^2 ./ tempcxy;


        end
        
    % end
    
    
    % methods
        
          function extract_feature(obj)
            % opt1 used to indicate parallel processing
            
            
            feature = obj.fast_extraction();
            obj.feature = feature;
            flattened_feature = [];
            for row = 1: size(feature, 1)
                flattened_feature = [flattened_feature, feature(row, row+1:end)];
            end
            obj.flattened_feature = flattened_feature(:);
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
            curstr = 'EEGWindowBandCoherence';
        end

    end
    methods(Access = protected)

        function window_interface = clone_window_and_fill_feature(obj, windowData)
            window_interface = EEGWindowBandCoherence();
            nchannels = windowData.num_channels;
            N = length(windowData.flattened_feature);
            assert(N == (nchannels * (nchannels - 1) / 2), 'band coherence, window recreation, dimsension mismatch');
            feature = zeros(nchannels, nchannels);
            used_ele = 0;

            for rind = 1: nchannels -1
                nele = nchannels - rind;
                feature(rind, rind+1 : nchannels) = windowData.flattened_feature(used_ele + 1: used_ele + nele);
                used_ele = used_ele + nele;
            end
            feature = eye(nchannels) + feature + feature';
            window_interface.feature = feature;
        end

    end
end