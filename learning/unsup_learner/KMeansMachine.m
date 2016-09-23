classdef KMeansMachine < handle
    
    properties
    centroids = [];
    num_clusters = 10;
    one_window = [];
    proportion = [];
    identifier = [];
    end

    methods
        % find centroids, separators or whatever
        function fit(obj, data_mat, data_windows)
            if nargin < 3
                data_windows = []
            end
            obj.identifier = 1: obj.num_clusters;
            
            % obj.one_window = data_windows(1);
            disp('starting k means...........');
            [idx, obj.centroids] = kmeans(data_mat, obj.num_clusters,'MaxIter',1000) ;
            cur_proportion = zeros(obj.num_clusters, 1);

            for lab  = obj.identifier
                cur_proportion(lab) = sum(idx == lab);
            end
            cur_proportion = sqrt(cur_proportion);
            obj.proportion = cur_proportion / sum(cur_proportion);

            hist(idx);
            title('kmeans distribution');
            disp('..........finishing kmeans clustering');
%             figure

%             plot(obj.centroids')
%             ss = 1:obj.num_clusters;
%             ss = arrayfun(@num2str, ss, 'UniformOutput', false);
% %             legend(ss)
% 
%             title('kmeans vectors')
        end

        % infer the class membership 
        function [idx] = infer(obj, feature_matrix)
            
            if isempty(obj.centroids)
                error('you need to fit kmeans model before inferring')
            end

            len = size(feature_matrix, 1);
            dists = zeros(len, obj.num_clusters);

            for col = 1: obj.num_clusters
                curentroid = obj.centroids(col, :);
                curdist_vec = feature_matrix - repmat(curentroid , len, 1);
                curdist = sqrt(sum(curdist_vec.^2, 2));
                dists(:, col) = curdist;
            end
            find_max_in_row = @(row) find(row == min(row));
            idx = arrayfun(@(row_ind) find_max_in_row(dists(row_ind, :)), 1:len);
        end


        function show_centroids(obj)
            first_window = obj.one_window;
            C = obj.centroids;
            k = obj.num_clusters;
            plot_limits = [min(min(C)), max(max(C))];
                            
            for curidx = 0:1: k               
                % figure()
                curfeature = C(curidx, :);
                first_window.plot_his_feature(curfeature(:), plot_limits)%, [0, 0.7]);%TODO remove limit
                title(sprintf('%d th component',curidx))

            end

        end

        function indicator = sampling(obj, num, X) % returns a (column) vector indicating whether to include current observation 
            idx = obj.infer(X);
            indicator = zeros(size(X, 1), 1);
            sampling_nums = [];
            fprintf('kmeans machine to sample %d out of %d', num, size(X, 1))
            sampling_nums = floor(num *obj.proportion);
            sampling_nums(end) = num - sum(sampling_nums(1: end-1)); % to make sure that numbers actually match
            % sampling_nums
            for ide = obj.identifier
                % find(idx == ide)
                indices = randsample(find(idx == ide), sampling_nums(ide));
                indicator(indices) = 1;
            end
            indicator = indicator == 1;
        end


     end



end
