classdef EEGWindowBandCoherence < EEGWindowInterface

    properties(Constant)
        band_cutoff = [30,40] % to be set as a static parameter
    end

    properties
        
        cxy
        f
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
            parfor i = 1:dim
            % for i = 1:dim
                curfeature = zeros(1,dim);
                for j= i: dim
                    x = raw_feature(i, :);
                    y = raw_feature(j, :);
                    [cxy, f] = mscohere(x,y,[],[],[],obj.Fs);
                    val = EEGWindowBandCoherence.get_coherence_band_sum(cxy,f);
                    curfeature(j) = val;
%                     feature(j,i) = val;
                end
                feature(i, :)= curfeature;
            end

            mcoh = feature + feature' - diag(diag(feature));
            
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
            tempcxy = (diag(feature) * diag(feature)').^0.5 ;
            if norm(tempcxy) < 1e-5
                disp(feature)
                disp(obj.real_timestamp)
            end
            mcoh = feature ./ tempcxy;


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
    end
end